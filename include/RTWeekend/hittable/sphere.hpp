#pragma once

#include <RTWeekend/hittable/hittable.hpp>

class sphere : public hittable
{
  public:
    sphere(const point3 &center, double radius) : center(center), radius(fmax(0, radius)) {}

    virtual bool hit(const ray &r, const interval &ray_t, hit_record &rec) const override;

  private:
    point3 center;
    double radius;
};