//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifdef MOOSE_MFEM_ENABLED

#include "MFEMDomainLFGradKernel.h"
#include "MFEMProblem.h"

registerMooseObject("MooseApp", MFEMDomainLFGardKernel);

InputParameters
MFEMDomainLFGardKernel::validParams()
{
  InputParameters params = MFEMKernel::validParams();
  params.addClassDescription("Adds the domain integrator to an MFEM problem for the linear form "
                             "$(f, v)_\\Omega$ "
                             "arising from the weak form of the forcing term $f$.");
  params.addParam<MFEMScalarCoefficientName>(
      "coefficient", "1.", "The name of the scalar coefficient f");
  return params;
}

MFEMDomainLFGardKernel::MFEMDomainLFGardKernel(const InputParameters & parameters)
  : MFEMKernel(parameters), _coef(getScalarCoefficient("coefficient"))
{    
  
  _product_u2_coeff =  new mfem::ProductCoefficient(_coef, _coef);
  _sum_coeff = new mfem::SumCoefficient(1.0, *_product_u2_coeff);
  _product_2u_coeff = new mfem::ProductCoefficient(2.0, _coef);

  // declares GradientGridFunctionCoefficient
  getMFEMProblem().getCoefficients().declareVector<mfem::GradientGridFunctionCoefficient>(
      name(), getMFEMProblem().getProblemData().gridfunctions.Get(_test_var_name));
}

mfem::LinearFormIntegrator *
MFEMDomainLFGardKernel::createNLActionIntegrator()
{
  mfem::VectorCoefficient & vec_coef = getMFEMProblem().getCoefficients().getVectorCoefficient(name());
  _product_coeff = new mfem::ScalarVectorProductCoefficient(*_sum_coeff, vec_coef);
  return new mfem::DomainLFGradIntegrator(*_product_coeff);
}

mfem::BilinearFormIntegrator *
MFEMDomainLFGardKernel::createBFIntegrator()
{
  mfem::VectorCoefficient & vec_coef = getMFEMProblem().getCoefficients().getVectorCoefficient(name());
  _dproduct_coeff = new mfem::ScalarVectorProductCoefficient(*_product_2u_coeff, vec_coef);
  _sum = new mfem::SumIntegrator;
  _sum->AddIntegrator(new mfem::DiffusionIntegrator(*_sum_coeff));
  _sum->AddIntegrator(new mfem::MixedDirectionalDerivativeIntegrator(*_dproduct_coeff));
  return _sum;
}

#endif
