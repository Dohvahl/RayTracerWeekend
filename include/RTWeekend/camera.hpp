#pragma once

#include <RTWeekend/hittable/hittable.hpp>

#include <RTWeekend/color.hpp>

class vec3;

// cppcheck-suppress [noConstructor]
class camera
{
  public:
    double aspect_ratio = 16.0 / 9.0;
    int image_width = 400;

    void render(const hittable &world);


  private:
    int image_height;// Rendered image height
    point3 center;// Camera center
    point3 pixel00_loc;// Location of pixel 0, 0
    vec3 pixel_delta_u;// Offset to pixel to the right
    vec3 pixel_delta_v;// Offset to pixel below

    void initialize();

    static color ray_color(const ray &ray_to_test, const hittable &world);
};