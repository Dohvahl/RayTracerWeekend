#pragma once

#include <RTWeekend/interval.hpp>
#include <RTWeekend/vec3.hpp>

class ray;

struct hit_record
{
    point3 p;
    vec3 normal;
    double t;
    bool front_face;

    void set_face_normal(const ray &r, const vec3 &outward_normal);
};

class hittable
{
  public:
    virtual ~hittable() = default;

    virtual bool hit(const ray &r, const interval &ray_t, hit_record &rec) const = 0;
};