# Definite Maxwell problem solved with Nedelec elements of the first kind
# based on MFEM Example 3.

omega=${fparse 2.0*3.14159265358979323846*50.0}  # angular frequency 2*PI
sigma=0.3278e8 # Siemens per meter (S/m) of the conductivity plate
nu=795774.715 #  (meters/Henry) = 1/magentic permiablity of free space
epsilon=8.85e-12 #Farads/m of free space

[Mesh]
  type = MFEMMesh
  file = ../mesh/team_coil_two_vols_plate_exterior_tet_m.msh
[]

[Problem]
  type = MFEMProblem
  numeric_type = complex
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
[]

[Variables]
  [a_field]
    type = MFEMComplexVariable
    fespace = HCurlFESpace
  []
[]

[AuxVariables]
  [b_field]
    type = MFEMComplexVariable
    fespace = HDivFESpace
  []
  [e_field]
    type = MFEMComplexVariable
    fespace = HCurlFESpace
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
  [tangential_a_bdr]
    type = MFEMComplexVectorTangentialDirichletBC
    variable = a_field
  #  boundary = 'Boundary' #free space
  []
[]

[FunctorMaterials]
  [Conductor]
    type = MFEMGenericFunctorMaterial
    prop_names = conductivity
    prop_values = 1.0
    block = 'First_half Second_half'
  []
[]

[Kernels]
  [curlcurl_A]
    type = MFEMComplexKernel
    variable = a_field
    [RealComponent]
      type = MFEMCurlCurlKernel
      coefficient = ${nu}
    []
  []

  [mass_plate]
    type = MFEMComplexKernel
    variable = a_field
    [ImagComponent]
      type = MFEMVectorFEMassKernel
      coefficient = ${fparse (omega*sigma)}
    []
    [RealComponent]
      type = MFEMVectorFEMassKernel
      coefficient = ${fparse -(omega*omega*epsilon)}
    []
    block = 'Plate'
  []

  [mass_free_space]
    type = MFEMComplexKernel
    variable = a_field
    [RealComponent]
      type = MFEMVectorFEMassKernel
      coefficient = ${fparse -(omega*omega*epsilon)}
    []
    block = 'Free_space'
  []

  [source]
    type = MFEMComplexKernel
    variable = a_field
    [RealComponent]
      type = MFEMVectorFEDomainLFKernel
      coefficient = e_field
    []
   block = 'First_half Second_half'
  []
[]


[Solver]
  type = MFEMSuperLU
  l_tol = 1e-12
  print_level = 1
  l_max_its = 100
[]

[Executioner]
  type = MFEMSteady
  device = cpu
[]

[MultiApps]
  [subapp]
    type = FullSolveMultiApp
    input_files = closed_coil.i
    execute_on = INITIAL
  []
[]

[Transfers]
  [from_sub]
    type = MultiAppMFEMShapeEvaluationTransfer
    source_variables = e_field
    variables = e_field
    from_multi_app = subapp
  []
[]

[Outputs]
  [ParaViewDataCollection]
    type = MFEMParaViewDataCollection
    file_base = OutputData/Magnetodynamic
    vtk_format = ASCII
  []
[]
 