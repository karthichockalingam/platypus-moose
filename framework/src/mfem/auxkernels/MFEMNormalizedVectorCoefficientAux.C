//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifdef MOOSE_MFEM_ENABLED

#include "MFEMNormalizedVectorCoefficientAux.h"

registerMooseObject("MooseApp", MFEMNormalizedVectorCoefficientAux);

InputParameters
MFEMNormalizedVectorCoefficientAux::validParams()
{
  InputParameters params = MFEMAuxKernel::validParams();
  params.addClassDescription("Normalizes a vector coefficient and projects it onto a vector MFEM auxvariable.");
  params.addRequiredParam<MFEMVectorCoefficientName>("vector_coefficient",
                                                     "Name of the vector coefficient to normalize and project.");
  return params;
}

MFEMNormalizedVectorCoefficientAux::MFEMNormalizedVectorCoefficientAux(const InputParameters & parameters)
  : MFEMAuxKernel(parameters), 
  _vec_coef(getVectorCoefficient("vector_coefficient")),
  _normalized_coef(_vec_coef)
  {
}

void
MFEMNormalizedVectorCoefficientAux::execute()
{
  _result_var.ProjectCoefficient(_normalized_coef);
}

#endif
