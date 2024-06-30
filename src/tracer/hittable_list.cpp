#include <RTWeekend/rtweekend.hpp>

#include <RTWeekend/hittable/hittable.hpp>
#include <RTWeekend/hittable/hittable_list.hpp>
#include <RTWeekend/interval.hpp>
#include <RTWeekend/ray.hpp>

void hittable_list::clear() { objects.clear(); }

void hittable_list::add(shared_ptr<hittable> object) { objects.push_back(object); }

bool hittable_list::hit(const ray &r, const interval &ray_t, hit_record &rec) const
{
    hit_record temp_rec;
    bool hit_anything = false;
    auto closest_so_far = ray_t.max;

    for (const auto &object : objects) {
        if (object->hit(r, { ray_t.min, closest_so_far }, temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }

    return hit_anything;
}
