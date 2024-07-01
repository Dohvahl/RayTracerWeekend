#include <RTWeekend/rtweekend.hpp>

#include <RTWeekend/camera.hpp>
#include <RTWeekend/color.hpp>
#include <RTWeekend/hittable/hittable.hpp>
#include <RTWeekend/ray.hpp>
#include <RTWeekend/vec3.hpp>

#include <algorithm>
#include <iostream>

void camera::render(const hittable &world)
{
    initialize();

    std::cout << "P3\n" << image_width << ' ' << image_height << "\n255\n";

    for (int i = 0; i < image_height; i++) {
        std::clog << "\rScanlines remaining: " << (image_height - i) << ' ' << std::flush;
        for (int j = 0; j < image_width; j++) {
            auto pixel_center = pixel00_loc + (i * pixel_delta_v) + (j * pixel_delta_u);
            auto ray_direction = pixel_center - center;
            ray const ray_to_test(center, ray_direction);

            auto pixel_color = ray_color(ray_to_test, world);
            write_color(std::cout, pixel_color);
        }
    }

    std::clog << "\r\nDone." << std::flush << "\n";
}

void camera::initialize()
{
    image_height = std::max(1, int(image_width / aspect_ratio));

    center = point3{ 0, 0, 0 };

    constexpr auto focal_length = 1.0;
    constexpr auto viewport_height = 2.0;
    auto viewport_width = viewport_height * (double(image_width) / image_height);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    auto viewport_u = vec3(viewport_width, 0, 0);
    auto viewport_v = vec3(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    pixel_delta_u = viewport_u / image_width;
    pixel_delta_v = viewport_v / image_height;

    // Calculate the location of the upper left pixel.
    const auto viewport_upper_left = center - vec3(0, 0, focal_length) - (viewport_u / 2) - (viewport_v / 2);
    pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);
}

color camera::ray_color(const ray &ray_to_test, const hittable &world)
{
    hit_record rec;
    if (world.hit(ray_to_test, { 0, infinity }, rec)) { return 0.5 * (rec.normal + color(1, 1, 1)); }

    // lerp b/w white and blue, based on Y coordinate
    vec3 const unit_direction = unit_vector(ray_to_test.direction());
    auto a = 0.5 * (unit_direction.y() + 1.0);
    return (1.0 - a) * color(1.0, 1.0, 1.0) + a * color(0.5, 0.7, 1.0);
}