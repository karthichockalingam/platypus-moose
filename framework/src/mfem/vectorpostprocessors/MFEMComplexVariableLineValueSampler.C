//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifdef MOOSE_MFEM_ENABLED

#include "MFEMComplexVariableLineValueSampler.h"

#include "libmesh/point.h"
#include "MooseError.h"
#include "MFEMProblem.h"

#include <vector>

registerMooseObject("MooseApp", MFEMComplexVariableLineValueSampler);

namespace mfem_complex_line_sampler
{
std::vector<Point>
generateLinePoints(const Point & start_point,
                   const Point & end_point,
                   unsigned int num_points,
                   const std::string & object_name)
{
  if (num_points < 2)
    mooseError("In MFEMComplexVariableLineValueSampler \"",
               object_name,
               "\": line must have at least 2 points, "
               "for single points use MFEMVariablePointValueSampler.");

  // initialize and populate vector with linearly-spaced points along line
  std::vector<Point> points;
  points.reserve(num_points);
  for (const auto i_point : make_range(num_points))
  {
    // fractional distance along line [0, 1]
    Real t = static_cast<Real>(i_point) / static_cast<Real>(num_points - 1);
    points.push_back(t * end_point + (1 - t) * start_point);
  }

  return points;
}
}

InputParameters
MFEMComplexVariableLineValueSampler::validParams()
{
  InputParameters params = MFEMComplexVariableValueSamplerBase::validParams();

  params.addClassDescription("Sample an MFEM variable along a specified line.");

  // these should not be of type libmesh::Point - need mfem::Point parsing
  params.addRequiredParam<Point>("start_point", "The beginning of the line");
  params.addRequiredParam<Point>("end_point", "The ending of the line");

  params.addRequiredParam<unsigned int>("num_points",
                                        "The number of points to sample along the line");

  return params;
}

MFEMComplexVariableLineValueSampler::MFEMComplexVariableLineValueSampler(const InputParameters & parameters)
  : MFEMComplexVariableValueSamplerBase(parameters,
                                 // can't call getParam as that requires initialized base class
                                 // so calling parameters.get directly
                                 mfem_complex_line_sampler::generateLinePoints(parameters.get<Point>("start_point"),
                                                    parameters.get<Point>("end_point"),
                                                    parameters.get<unsigned int>("num_points"),
                                                    parameters.getObjectName()))
{
}

#endif // MOOSE_MFEM_ENABLED
