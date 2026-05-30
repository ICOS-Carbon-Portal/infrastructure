// Typed `loop:` — bind a task's `item` references to the loop's element type.
//
// In Ansible a looped task references the current element as `item` (or
// `item.attr`). Written as raw strings (`"{{ item.src }}"`) those references are
// unchecked — a typo like `item.scr` is invisible. But for an inline loop list
// the element type is statically present, so we can bind the two:
//
//   loopOver(
//     [{ src: "logrotate.conf" }, { src: "x", mode: "+x" }] as Row[],
//     (item) => ({
//       name: "Copy files",
//       template: { src: item.src, dest: item.dest },   // item.src checked
//     }),
//   )
//
// `item.src` renders to "{{ item.src }}"; `item.scr` is a compile error. The
// bare `item` (scalar loops) renders to "{{ item }}".
import type { Task } from "./ansible.ts";
import type { Ref } from "./vars.ts";

/**
 * A typed accessor for the loop variable. For an object element type its keys
 * are exposed as refs (`item.src` -> "{{ item.src }}"); the value itself is a
 * `Ref` so a bare `item` works in scalar loops.
 */
export type Item<T> = T extends object
  ? Ref & { readonly [K in keyof T]-?: Ref }
  : Ref;

function itemProxy<T>(): Item<T> {
  return new Proxy(function () {}, {
    get(_t, key) {
      if (
        key === "toJSON" || key === "toString" || key === Symbol.toPrimitive
      ) {
        return () => "{{ item }}";
      }
      return `{{ item.${String(key)} }}`;
    },
  }) as unknown as Item<T>;
}

/**
 * Build a looped task. `items` is the loop list (its element type drives `item`
 * checking); `body` returns the task, referencing the element via `item`.
 */
export function loopOver<T>(
  items: readonly T[],
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
): Task {
  return { ...body(itemProxy<T>()), loop: items as unknown as Task["loop"] };
}

/** As `loopOver`, but emits the legacy `with_items:` key instead of `loop:`. */
export function withItemsOver<T>(
  items: readonly T[],
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
): Task {
  return {
    ...body(itemProxy<T>()),
    with_items: items as unknown as Task["with_items"],
  };
}
