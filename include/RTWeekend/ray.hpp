#pragma once

#include "vec3.hpp"

class ray
{
public:
	ray() {}
	ray(const point3 &origin, const vec3 &direction) : orig(origin), dir(direction) {}

	const point3 &origin() const;
	const vec3 &direction() const;

	point3 at(double t) const;

private:
	point3 orig;
	vec3 dir;
};