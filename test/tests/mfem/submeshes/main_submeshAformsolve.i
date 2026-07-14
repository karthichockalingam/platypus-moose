# Definite Maxwell problem solved with Nedelec elements of the first kind
# based on MFEM Example 3.

omega=${fparse 2.0*3.14159265358979323846*50.0}  # angular frequency 2*PI
sigma_vac = 0.0
sigma_coil = 5.8e6
sigma_target = 0.3278e8 # Siemens per meter (S/m) of the conductivity plate
nu=795774.715 #  (meters/Henry) = 1/magentic permiablity of free space
epsilon= 8.8541878176e-12 #Farads/m of free space

[Mesh]
  type = MFEMMesh
  file = ../mesh/team_coil_two_vols_plate_exterior_tet_m.msh
[]

[Problem]
  type = MFEMProblem
  numeric_type = complex
[]

[SubMeshes]
  [coil_complement]
    type = MFEMDomainSubMesh
    block = 'Free_space Plate'
  []
[]

[FESpaces]
  [HCurlFESpace]
    type = MFEMVectorFESpace
    fec_type = ND
    fec_order = FIRST
  []
  [HDivFESpace]
    type = MFEMVectorFESpace
    fec_type = RT
    fec_order = CONSTANT
  []
  [SubmeshHCurlFESpace]
      type = MFEMVectorFESpace
      fec_type = ND
      fec_order = FIRST
      submesh = coil_complement
  []
  [SubmeshHDivFESpace]
    type = MFEMVectorFESpace
    fec_type = RT
    fec_order = CONSTANT
    submesh = coil_complement
  []
[]

[Variables]
  [a_field]
    type = MFEMComplexVariable
    fespace = SubmeshHCurlFESpace
  []
[]

[AuxVariables]
  [b_field]
    type = MFEMComplexVariable
    fespace = SubmeshHDivFESpace
  []
  [source_a_field]
    type = MFEMComplexVariable
    fespace = HCurlFESpace
  []
  [coil_complement_source_a_field] #a field defined on submesh representing domain excluding coil volume but including coil surface
        type = MFEMComplexVariable
        fespace = SubmeshHCurlFESpace
  []
[]

[AuxKernels]
  [curl]
    type = MFEMComplexCurlAux
    variable = b_field
    source = a_field
    execute_on = TIMESTEP_END
  []
[]

[BCs]
    # A = iE/w on coil surface
    [coil_surface_a_field] 
        type = MFEMComplexVectorTangentialDirichletBC
        variable = a_field
        vector_coefficient_real = coil_complement_source_a_field_imag
        vector_coefficient_imag = coil_complement_source_a_field_real
        boundary = 7
    []
    [tangential_a_bdr]
        type = MFEMComplexVectorTangentialDirichletBC
        variable = a_field
        boundary = 'Boundary' #free space
    []
[]

[Functions]
    # (i * \omega * \sigma - \omega^2 * \epsilon0)* A represented as (massCoef + i*loss_coef)*A 
    # where massCoef = -omega^2 * epsilon0, lossCoef = \omega * sigma
    [mass_coef]
        type = ParsedFunction
        expression = -${epsilon}*${omega}^2
    []
    [loss_coef_vac]
        type = ParsedFunction
        expression = ${omega}*${sigma_vac}
    []
    [loss_coef_coil]
        type = ParsedFunction
        expression = ${omega}*${sigma_coil}
    []
    [loss_coef_target]
        type = ParsedFunction
        expression = ${omega}*${sigma_target}
    []
[]

[FunctorMaterials]
    #expose \sigma, nu, mass/loss for j*\omega*\sigma
    [vacuum]
        type = MFEMGenericFunctorMaterial
        prop_names = 'massCoef lossCoef sigma nu'
        prop_values = 'mass_coef loss_coef_vac ${sigma_vac} ${nu}'
        block = 'Free_space'
    []
    [coil]
        type = MFEMGenericFunctorMaterial
        prop_names = 'massCoef lossCoef sigma nu'
        prop_values = 'mass_coef loss_coef_coil ${sigma_coil} ${nu}'
        block = 'First_half Second_half'
    []
    [target]
        type = MFEMGenericFunctorMaterial
        prop_names = 'massCoef lossCoef sigma nu '
        prop_values = 'mass_coef loss_coef_target ${sigma_target} ${nu} '
        block = 'Plate'
    []
[]

[Kernels]
  [curlcurl]
    type = MFEMComplexKernel
    variable = a_field
    [RealComponent]
      type = MFEMCurlCurlKernel
      coefficient = ${nu}
    []
  []

  [conductive_mass_complex]
    type = MFEMComplexKernel
    variable = a_field
    [RealComponent]
      type = MFEMVectorFEMassKernel
      coefficient = massCoef # = - (omega**2)*epsilon
    []
    [ImagComponent]
      type = MFEMVectorFEMassKernel
      coefficient = loss_coef_target
      block = 'Plate'
    []
  []
[]


[Solver]
  type = MFEMSuperLU
[]

[Executioner]
  type = MFEMSteady
  device = cpu
[]

[MultiApps]
  [subapp]
    type = FullSolveMultiApp
    input_files = closed_coil_submeshlaplacesolve.i
    execute_on = INITIAL
  []
[]

[Transfers]
  active = 'from_sub_source_a_field submesh_transfer_to_coil_complement'
  [from_sub_source_a_field]
    type = MultiAppMFEMShapeEvaluationTransfer
    source_variables = source_a_field
    variables = source_a_field
    from_multi_app = subapp
  []
  [submesh_transfer_to_coil_complement]
    type = MFEMComplexSubMeshTransfer
    from_variable = source_a_field
    to_variable = coil_complement_source_a_field
    execute_on = INITIAL
  []  
[]

[Outputs]
  [GlobalParaViewDataCollection]
    type = MFEMParaViewDataCollection
    file_base = OutputData/AFormSolve
    vtk_format = ASCII
  []
  [SubmeshParaViewDataCollection]
    type = MFEMParaViewDataCollection
    file_base = OutputData/SubmeshAFormSolve
    vtk_format = ASCII
    submesh = coil_complement
  []
[]
 