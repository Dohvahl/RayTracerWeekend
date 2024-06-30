#pragma once

#include <RTWeekend/vec3.hpp>
#include <ostream>

using color = vec3;

void write_color(std::ostream &out, const color &pixel_color);