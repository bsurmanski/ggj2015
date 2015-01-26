import "vec.wl"

class Entity {
    vec4 position
    float rotation

    static Entity first

    Entity next
    weak Entity prev

    static void setFirst(Entity e) first = e
    static Entity getFirst() return first
    bool isDead() return false

    static void add(Entity e) {
        if(!first) {
            first = e
        } else {
            first.prev = e
            e.next = first
            first = e
        }
    }

    static void removeAll() {
        // ideally the refcounters would handle deleting all these
        first.next = null
        first = null
    }

    float nummies() return 0.01f
    float yummyNummies() return 0.0f
    bool areYouCookie() return false

    void update(float dt) {
    }

    void draw(mat4 view) {}

}

void updateEntities(float dt) {
    Entity e = Entity.first
    while(e) {
        e.update(dt)
        if(e.isDead()) {
            Entity del = e
            if(e.prev) e.prev.next = e.next
            if(e.next) e.next.prev = e.prev
            if(e == Entity.first) (Entity.first = e.next)
            e = e.next
            delete del
            continue
        }
        e = e.next
    }
}

void drawEntities(mat4 view) {
    Entity e = Entity.first
    while(e) {
        e.draw(view)
        e = e.next
    }
}
