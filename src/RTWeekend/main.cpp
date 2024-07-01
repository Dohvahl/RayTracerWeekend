#include <RTWeekend/rtweekend.hpp>

#include <RTWeekend/camera.hpp>
#include <RTWeekend/vec3.hpp>

#include <RTWeekend/hittable/hittable_list.hpp>
#include <RTWeekend/hittable/sphere.hpp>


int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv)
{
    hittable_list world;

    world.add(make_shared<sphere>(point3{ 0, -100.5, -1 }, 100));
    world.add(make_shared<sphere>(point3{ 0, 0, -1 }, 0.5));

    camera cam;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.render(world);
}
