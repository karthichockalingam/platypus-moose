//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifdef MOOSE_MFEM_ENABLED

#pragma once

#include "MFEMAuxKernel.h"

/**
 * Normalizes a vector coefficient and projects it onto a vector-valued auxvariable.
 */
class MFEMNormalizedVectorCoefficientAux : public MFEMAuxKernel
{
public:
  static InputParameters validParams();

  MFEMNormalizedVectorCoefficientAux(const InputParameters & parameters);

  virtual ~MFEMNormalizedVectorCoefficientAux() = default;

  virtual void execute() override;

protected:
  /// Reference to source coefficient.
  mfem::VectorCoefficient & _vec_coef;
  mfem::NormalizedVectorCoefficient _normalized_coef;
};

#endif
