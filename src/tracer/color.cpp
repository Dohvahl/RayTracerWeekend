#include <RTWeekend/color.hpp>
#include <RTWeekend/interval.hpp>
#include <ostream>

void write_color(std::ostream &out, const color &pixel_color)
{
    auto r = linear_to_gamma(pixel_color.x());
    auto g = linear_to_gamma(pixel_color.y());
    auto b = linear_to_gamma(pixel_color.z());

    // Translate the [0,1] component values to the byte range [0,255].
    static const interval intensity{ 0.000, 0.999 };
    int const rbyte = int(256 * intensity.clamp(r));
    int const gbyte = int(256 * intensity.clamp(g));
    int const bbyte = int(256 * intensity.clamp(b));

    // Write out the pixel color components.
    out << rbyte << ' ' << gbyte << ' ' << bbyte << '\n';
}