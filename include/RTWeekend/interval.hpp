#pragma once

#include "rtweekend.hpp"


class interval
{
  public:
    double min, max;

    interval() : min(+infinity), max(-infinity) {}
    interval(double min, double max) : min(min), max(max) {}

    double size() const;
    bool contains(double x) const;
    bool surrounds(double x) const;

    static const interval empty, universe;
};
