#include <RTWeekend/hittable/hittable.hpp>
#include <RTWeekend/hittable/sphere.hpp>
#include <RTWeekend/ray.hpp>
#include <RTWeekend/vec3.hpp>
#include <cmath>

bool sphere::hit(const ray &r, double ray_tmin, double ray_tmax, hit_record &rec) const
{
    vec3 const oc = center - r.origin();
    auto a = r.direction().length_squared();
    auto h = dot(r.direction(), oc);
    auto c = oc.length_squared() - radius * radius;

    auto discriminant = (h * h) - (a * c);
    if (discriminant < 0) { return false; }

    auto sqrtd = sqrt(discriminant);

    // find nearest root that lies in the acceptable range
    auto root = (h - sqrtd) / a;
    if (root <= ray_tmin || ray_tmax <= root) {
        root = (h + sqrtd) / a;
        if (root <= ray_tmin || ray_tmax <= root) { return false; }
    }

    rec.t = root;
    rec.p = r.at(rec.t);
    vec3 const outward_normal = (rec.p - center) / radius;
    rec.set_face_normal(r, outward_normal);

    return true;
}