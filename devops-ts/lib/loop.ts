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
import { expr, type Ref } from "./template.ts";

/**
 * A typed accessor for the loop variable. For an object element type its keys
 * are exposed as refs (`item.src` -> "{{ item.src }}"); the value itself is a
 * `Ref` so a bare `item` works in scalar loops.
 */
export type Item<T> = T extends object
  ? Ref & { readonly [K in keyof T]-?: Ref }
  : Ref;

function itemProxy<T>(): Item<T> {
  // Base template for the bare loop variable: `{{ item }}`. Wrapping a real
  // `Template` (rather than a plain function) makes the proxy `instanceof
  // Template`, so it splices into `tmpl` as a structured ref part and renders as
  // a double-quoted ref scalar — never as a literal string that re-embeds
  // `{{ }}`. Template's own members (`parts`, `toText`, `toString`, symbols)
  // pass through to the base; any other property is a field ref `item.<key>`.
  const base = expr("item");
  return new Proxy(base, {
    get(target, key, receiver) {
      if (typeof key === "symbol" || key in target) {
        return Reflect.get(target, key, receiver);
      }
      return expr(`item.${String(key)}`);
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

/**
 * As `loopOver`, but for a loop over a VARIABLE (`loop: "{{ some_list }}"`).
 * The element type cannot be inferred from a variable, so the caller asserts
 * it; `item.<key>` references are then checked against that assertion — a
 * weaker guarantee than `loopOver`'s inference, but it still catches typos and
 * documents the element shape at the loop site.
 *
 *   loopOverVar<{ name: string; key: string }>(
 *     expr("user_conf.create_users").default([]),
 *     (item) => ({ authorized_key: { user: item.name, key: item.key } }),
 *   )
 */
export function loopOverVar<T>(
  source: Ref,
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
): Task {
  return { ...body(itemProxy<T>()), loop: source as unknown as Task["loop"] };
}

/** As `loopOverVar`, but emits the legacy `with_items:` key. */
export function withItemsOverVar<T>(
  source: Ref,
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
): Task {
  return {
    ...body(itemProxy<T>()),
    with_items: source as unknown as Task["with_items"],
  };
}
