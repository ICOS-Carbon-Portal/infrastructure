// Split a string into ordered segments of literal text and Jinja interpolations
// (`{{ ... }}` / `{% ... %}`). Shared by the structured-template codemod and
// gen-data so they agree on edge cases.
//
// The scanner tracks quotes inside an interpolation so the closing `}}`/`%}` is
// found correctly even for `lookup('template','x')` or escapes like `{{ '{{{' }}`.

export type Segment =
  | { kind: "lit"; text: string }
  | {
    kind: "interp";
    delim: "{{" | "{%";
    raw: string; // full text incl. braces, exactly as written
    inner: string; // trimmed expression between the braces
    /** True only for a plain `{{ <inner> }}` (single spaces, no braces in inner). */
    canonical: boolean;
  };

/** If `src` has an interpolation starting at `i`, read it; else null. */
export function readInterpAt(
  src: string,
  i: number,
): { seg: Extract<Segment, { kind: "interp" }>; end: number } | null {
  const open = src.slice(i, i + 2);
  if (open !== "{{" && open !== "{%") return null;
  const close = open === "{{" ? "}}" : "%}";
  let j = i + 2;
  let quote: string | null = null;
  while (j < src.length) {
    const c = src[j];
    if (quote) {
      if (c === quote) quote = null;
      j++;
      continue;
    }
    if (c === "'" || c === '"') {
      quote = c;
      j++;
      continue;
    }
    if (src.slice(j, j + 2) === close) break;
    j++;
  }
  if (j >= src.length) return null; // no close
  const raw = src.slice(i, j + 2);
  const inner = src.slice(i + 2, j).trim();
  const canonical = open === "{{" && raw === `{{ ${inner} }}` &&
    !/[{}]/.test(inner);
  return {
    seg: { kind: "interp", delim: open as "{{" | "{%", raw, inner, canonical },
    end: j + 2,
  };
}

export function parseJinja(src: string): Segment[] {
  const segs: Segment[] = [];
  let i = 0;
  let lit = "";
  const flushLit = () => {
    if (lit) segs.push({ kind: "lit", text: lit });
    lit = "";
  };
  while (i < src.length) {
    const r = readInterpAt(src, i);
    if (r) {
      flushLit();
      segs.push(r.seg);
      i = r.end;
    } else {
      lit += src[i];
      i++;
    }
  }
  flushLit();
  return segs;
}

/** A bare Jinja identifier (`foo`, `foo_bar`) — eligible to become `V.foo`. */
export function isBareIdent(s: string): boolean {
  return /^[A-Za-z_][A-Za-z0-9_]*$/.test(s);
}
