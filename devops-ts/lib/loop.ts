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
import type { Task } from "./ansible/task.ts";
import { type Ref, varProxy } from "./template.ts";

/**
 * A typed accessor for the loop variable. For an object element type its keys
 * are exposed as refs (`item.src` -> "{{ item.src }}"); the value itself is a
 * `Ref` so a bare `item` works in scalar loops.
 */
export type Item<T> = T extends object
  ? Ref & { readonly [K in keyof T]-?: Ref }
  : Ref;

function itemProxy<T>(varName = "item"): Item<T> {
  // The loop variable is a nested-ref proxy: bare `{{ item }}` (or the custom
  // `loop_var`), and any field access is `{{ item.<key> }}`. This is exactly
  // `varProxy` (the runtime behind `V.x.y`); the `Item<T>` cast supplies the
  // element-typed field list.
  return varProxy(varName) as unknown as Item<T>;
}

/**
 * Loop options. `loopVar` renames the element variable (Ansible's
 * `loop_control: { loop_var }`); the typed item refs then render as
 * `<loopVar>.<key>` and the task emits the matching `loop_control`.
 */
export interface LoopOpts {
  loopVar?: string;
}

function withLoopControl(task: Task, opts?: LoopOpts): Task {
  if (opts?.loopVar) task.loop_control = { loop_var: opts.loopVar };
  return task;
}

/**
 * Build a looped task. `items` is the loop list (its element type drives `item`
 * checking); `body` returns the task, referencing the element via `item`.
 */
export function loopOver<T>(
  items: readonly T[],
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
  opts?: LoopOpts,
): Task {
  return withLoopControl(
    {
      ...body(itemProxy<T>(opts?.loopVar)),
      loop: items as unknown as Task["loop"],
    },
    opts,
  );
}

/** As `loopOver`, but emits the legacy `with_items:` key instead of `loop:`. */
export function withItemsOver<T>(
  items: readonly T[],
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
  opts?: LoopOpts,
): Task {
  return withLoopControl({
    ...body(itemProxy<T>(opts?.loopVar)),
    with_items: items as unknown as Task["with_items"],
  }, opts);
}

/**
 * As `loopOver`, but for a loop over a VARIABLE (`loop: "{{ some_list }}"`).
 * The element type cannot be inferred from a variable, so the caller asserts
 * it; `item.<key>` references are then checked against that assertion — a
 * weaker guarantee than `loopOver`'s inference, but it still catches typos and
 * documents the element shape at the loop site.
 *
 *   loopOverVar<{ name: string; key: string }>(
 *     V.user_conf.create_users.default([]),
 *     (item) => ({ authorized_key: { user: item.name, key: item.key } }),
 *   )
 */
export function loopOverVar<T>(
  source: Ref,
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
  opts?: LoopOpts,
): Task {
  return withLoopControl(
    {
      ...body(itemProxy<T>(opts?.loopVar)),
      loop: source as unknown as Task["loop"],
    },
    opts,
  );
}

/** As `loopOverVar`, but emits the legacy `with_items:` key. */
export function withItemsOverVar<T>(
  source: Ref,
  body: (item: Item<T>) => Omit<Task, "loop" | "with_items">,
  opts?: LoopOpts,
): Task {
  return withLoopControl({
    ...body(itemProxy<T>(opts?.loopVar)),
    with_items: source as unknown as Task["with_items"],
  }, opts);
}
