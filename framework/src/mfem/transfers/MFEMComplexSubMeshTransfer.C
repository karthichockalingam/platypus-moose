//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifdef MOOSE_MFEM_ENABLED

#include "MFEMComplexSubMeshTransfer.h"
#include "MFEMProblem.h"

registerMooseObject("MooseApp", MFEMComplexSubMeshTransfer);

InputParameters
MFEMComplexSubMeshTransfer::validParams()
{
  InputParameters params = MFEMExecutedObject::validParams();
  params.registerBase("MFEMSubMeshTransfer");
  params.addClassDescription("Class to transfer MFEM variable data to or from a restricted copy of "
                             "the variable defined on "
                             " a subspace of an MFEMMesh, represented as an MFEMSubMesh.");
  MFEMExecutedObject::addRequiredDependencyParam<VariableName>(
      params,
      "from_variable",
      "MFEM variable to transfer data from. Can be defined on either the parent mesh or a "
      "submesh of it.");
  params.addRequiredParam<VariableName>("to_variable",
                                        "MFEM variable to transfer data into. Can be defined on "
                                        "either the parent mesh or a submesh of it.");

  return params;
}

MFEMComplexSubMeshTransfer::MFEMComplexSubMeshTransfer(const InputParameters & parameters)
  : MFEMExecutedObject(parameters),
    _source_var_name(getParam<VariableName>("from_variable")),
    _source_var(*getMFEMProblem().getComplexGridFunction(_source_var_name)),
    _result_var_name(getParam<VariableName>("to_variable")),
    _result_var(*getMFEMProblem().getComplexGridFunction(_result_var_name))
{
}

std::optional<std::string>
MFEMComplexSubMeshTransfer::suppliedVariableName() const
{
  return _result_var_name;
}

void
MFEMComplexSubMeshTransfer::execute()
{
  mfem::ParSubMesh::Transfer(_source_var.real(), _result_var.real());
  mfem::ParSubMesh::Transfer(_source_var.imag(), _result_var.imag());
}

#endif
