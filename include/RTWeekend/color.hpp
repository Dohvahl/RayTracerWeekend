#pragma once

#include <RTWeekend/vec3.hpp>
#include <ostream>

using color = vec3;

inline double linear_to_gamma(double linear_component)
{
    if (linear_component > 0.0) { return sqrt(linear_component); }
    return 0.0;
}

void write_color(std::ostream &out, const color &pixel_color);