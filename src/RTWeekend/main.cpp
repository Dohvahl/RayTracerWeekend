#include <RTWeekend/rtweekend.hpp>

#include <chrono>
#include <iomanip>
#include <iostream>

#include <RTWeekend/camera.hpp>
#include <RTWeekend/vec3.hpp>

#include <RTWeekend/hittable/hittable_list.hpp>
#include <RTWeekend/hittable/sphere.hpp>


template<typename Functor> void timer(Functor f)
{
    auto start = std::chrono::high_resolution_clock::now();

    f();

    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start);
    std::clog << "Solution took " << std::fixed << duration.count() * 10e-6 << "ms" << std::setprecision(4) << "\n";
}


int main([[maybe_unused]] int argc, [[maybe_unused]] char **argv)
{
    hittable_list world;

    world.add(make_shared<sphere>(point3{ 0, -100.5, -1 }, 100));
    world.add(make_shared<sphere>(point3{ 0, 0, -1 }, 0.5));

    camera cam;
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;
    cam.reflectance_factor = 0.5;

    timer([&]() { cam.render(world); });
}
