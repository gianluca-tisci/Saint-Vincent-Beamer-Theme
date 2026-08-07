# Saint Vincent — project notes

Beamer theme + lecture-notes class for economics, sharing one core with the
[problem-set template](https://github.com/gianluca-tisci/Latex_Template_Economics_ProblemSet).

## Architecture

```
tex/almacore.sty                 shared core — class-agnostic
tex/svnotes.sty                  article wrapper (lecture notes)
tex/beamerthemeSaintVincent.sty  the slide theme
macros/                          notation modules (micro / metrics / macro)
templates/{beamer,notes}/        self-contained, Overleaf-ready
```

**The one rule.** `almacore.sty` must load cleanly under *both* `article` and
`beamer`, so it may only require beamer-safe packages: `xcolor`, `tikz`,
`tcolorbox`, `etoolbox`, `amsmath`, `fancyvrb`, `booktabs`, `tabularx`,
`anyfontsize`, optionally `pgfplots`. Anything page-based — `geometry`,
`fancyhdr`, `titlesec`, `hyperref` setup, sectioning, margin notes — belongs in
a wrapper. Breaking this rule is the failure mode that turned Jambro's two
themes into two 50KB files with duplicated colour and pencil code.

## Hard conventions

- **The body font is never changed.** Nothing touches
  `\familydefault`/`\rmdefault`/`\sfdefault`, and no
  `\setbeamerfont{...}{family=...}`. Style by size, weight and colour only.
  The ONE exception is `\hand`, a scoped `\fontfamily{augie}` switch for
  handwritten annotations, which never leaks outside its group. Augie ships in
  `texlive-fonts-extra`; if absent it degrades to italic with a warning.
- **One accent colour, and nothing red outside alert blocks.** `almaaccent`
  in `almacore.sty` is the single knob; `\memo` and `\NB` are grey. The
  Beamer `alertblock` is the one place `almaalert` is still used, because an
  alert that looks like everything else is not an alert.
- **Mix tints against the background, not white.** In the theme write
  `svaccent!12!svbg`, never `svaccent!12` — the latter mixes with white and
  produces near-white blocks in `night` mode. This was a real bug.
- **`almacore.sty` is authored in the problem-set repo** and vendored here.
  `tools/sync-templates.sh --check` catches drift and warns if a sibling clone
  differs.

## Build and verify

```bash
tools/sync-templates.sh            # mirror tex/ + macros/ into templates/
tools/sync-templates.sh --check    # fail if templates/ is stale

cd templates/beamer && latexmk -pdf Main.tex
cd templates/notes  && latexmk -pdf main.tex
```

Alternative modes need a **wrapper .tex**, not inline TeX on the command line —
`latexmk` treats a leading backslash as a filename and stops with "bad
filename(s)":

```bash
printf '%s\n' '\PassOptionsToPackage{hidememo}{svnotes}' '\input{main.tex}' > clean.tex
latexmk -pdf clean.tex
```

Local TeX install used while developing:

```bash
apt-get install -y --no-install-recommends texlive-latex-base \
  texlive-latex-recommended texlive-latex-extra texlive-pictures \
  texlive-science texlive-fonts-recommended texlive-bibtex-extra latexmk
```

## Gotchas hit while building this

- Boxes are drawn as FOUR separate strokes whose corners overshoot by ~1pt
  (`\alma@sketchbox`), not as one `rectangle` path. A single path keeps four
  mathematically perfect corners and reads as mechanical however well it is
  decorated. Past ~1.5pt of overshoot it reads as careless instead.
- The pencil is `random steps` with a LONG segment (3mm) and a tiny amplitude
  (0.2pt) on a 0.9pt line at `!80`. Frequency is what matters: short segments
  give per-point noise, and `snake` at a 1.3mm wavelength corrugates a short
  box and kinks at corners. Two traps: `snake`'s segment length is a
  WAVELENGTH, so a long one fails with "Dimension too large" on short paths;
  and `decorate` plus `rounded corners` throws the same error.
- `\ifx\foo\empty` is false for a `\newcommand`-defined empty macro —
  `\newcommand` makes `\long` macros and `\empty` is not `\long`, so `\ifx`
  compares the prefixes. Use etoolbox's `\ifdefempty`.
- Annotation arrows (`\marker` + `\handnote`/`almaoverlay`) use
  `remember picture` and need TWO passes. The arrowhead is added with
  `arrows.meta` on top of the decorated shaft, since `decorate` mangles a tip.
- A `[fragile]` beamer frame needs `\end{frame}` alone on its own line.
- `\bibliographystyle` must precede `\bibliography`, and `\bibliography` takes
  no `.bib` extension. The original `Main.tex` had both wrong.
- tocloft's `\newlistof` creates its own counter, which collides with the
  `almabox` counter `almacore` already defines. `\listofboxes` therefore uses
  `\addcontentsline` + `\@starttoc` directly.
- Naming: an environment called `part` would clobber LaTeX's `\part`. The
  problem-set repo uses `qpart` for the same reason.
- Option naming: never call an option `draft` or `final` — both are standard
  *class* options and LaTeX forwards global class options to every package.

## State

Done: shared core vendored, `svnotes.sty`, `beamerthemeSaintVincent.sty`
(standalone — no SimplePlus dependency), both demo templates, README, CI,
sync script with drift check.

Possible next steps: a `handout` option for 2×1 printing; `\listoffigures`
styling in the notes class; a combined release workflow that publishes the
Overleaf ZIPs from both repos together.
