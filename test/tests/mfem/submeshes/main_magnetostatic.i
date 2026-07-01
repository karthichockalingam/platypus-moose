# Definite Maxwell problem solved with Nedelec elements of the first kind
# based on MFEM Example 3.

[Mesh]
  type = MFEMMesh
  file = ../mesh/team_coil_two_vols_plate_exterior_tet_m.msh
[]

[Problem]
  type = MFEMProblem
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
    type = MFEMVariable
    fespace = HCurlFESpace
  []
[]

[AuxVariables]
  [b_field]
    type = MFEMVariable
    fespace = HDivFESpace
  []
  [e_field]
    type = MFEMVariable
    fespace = HCurlFESpace
  []
[]

[AuxKernels]
  [curl]
    type = MFEMCurlAux
    variable = b_field
    source = a_field
    execute_on = TIMESTEP_END
  []
[]

[BCs]
  [tangential_a_bdr]
    type = MFEMVectorTangentialDirichletBC
    variable = a_field
    #boundary = '1'
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
  [curlcurl]
    type = MFEMCurlCurlKernel
    variable = a_field
  []
  [source]
    type = MFEMMixedVectorMassKernel
    variable = a_field
    trial_variable = e_field
    coefficient = conductivity
    block = 'First_half Second_half'
  []
[]

[Preconditioner]
  [ams]
    type = MFEMHypreAMS
    fespace = HCurlFESpace
    singular = true
    print_level = 2
  []
[]

[Solver]
  type = MFEMHypreGMRES
  preconditioner = ams
  l_tol = 1e-12
  print_level = 2
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
    type = MultiAppMFEMCopyTransfer
    source_variables = e_field
    variables = e_field
    from_multi_app = subapp
  []
[]

[Outputs]
  [ParaViewDataCollection]
    type = MFEMParaViewDataCollection
    file_base = OutputData/Magnetostatic
    vtk_format = ASCII
  []
[]
 