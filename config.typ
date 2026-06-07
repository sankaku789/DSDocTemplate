#import "@preview/codelst:2.0.2": *

#let fonts = yaml("config.yaml").font-setting
#let settings = yaml("config.yaml").document-setting
#let meta = yaml("config.yaml").document-meta

// デジタル庁デザインシステムのトークンを、Typst/PDF向けに必要な分だけ定義する。
// 色名は公式デザイントークンに近い名前を残し、用途が追いやすいようにしている。
#let dads-color = (
  white: rgb("#ffffff"),
  black: rgb("#000000"),
  gray-50: rgb("#f2f2f2"),
  gray-100: rgb("#e6e6e6"),
  gray-200: rgb("#cccccc"),
  gray-300: rgb("#b3b3b3"),
  gray-500: rgb("#7f7f7f"),
  gray-536: rgb("#767676"),
  gray-700: rgb("#4d4d4d"),
  gray-800: rgb("#333333"),
  gray-900: rgb("#1a1a1a"),
  blue-50: rgb("#e8f1fe"),
  blue-100: rgb("#d9e6ff"),
  blue-300: rgb("#9db7f9"),
  blue-500: rgb("#4979f5"),
  blue-800: rgb("#0031d8"),
  blue-900: rgb("#0017c1"),
  blue-1100: rgb("#000071"),
  cyan-50: rgb("#e9f7f9"),
  cyan-800: rgb("#008299"),
  green-50: rgb("#e6f5ec"),
  green-800: rgb("#197a4b"),
  yellow-50: rgb("#fbf5e0"),
  yellow-900: rgb("#927200"),
  orange-50: rgb("#ffeee2"),
  orange-800: rgb("#c74700"),
  red-50: rgb("#fdeeee"),
  red-900: rgb("#ce0000"),
)

// 余白スケール。デザインシステムの8 CSS px基準をPDF向けに換算する。
// 1 CSS px = 0.75pt として、8px/24px/64pxの関係性を保つ。
#let space-8 = 6pt
#let space-16 = 12pt
#let space-24 = 18pt
#let space-32 = 24pt
#let space-64 = 48pt

// config.yamlに任意項目がない場合でも落ちないように値を取り出す。
#let meta-value(key, fallback: "") = {
  if key in meta {
    meta.at(key)
  } else {
    fallback
  }
}

// authorは文字列でも配列でも受けられるようにする。
#let format-authors(authors) = {
  if type(authors) == array {
    authors.join("、")
  } else {
    str(authors)
  }
}

// date: auto の場合はコンパイル日、それ以外は YYYY-MM-DD を読む。
#let doc-date() = {
  if meta.date == "auto" {
    datetime.today()
  } else {
    let date-lst = meta.date.split("-")
    datetime(
      year: int(date-lst.at(0)),
      month: int(date-lst.at(1)),
      day: int(date-lst.at(2)),
    )
  }
}

// セクション境界や表紙で使う横罫線。
#let rule(color: dads-color.gray-200, thickness: 0.6pt) = {
  line(length: 100%, stroke: (paint: color, thickness: thickness))
}

// 文書全体の既定スタイルを設定するメイン関数。
// main.typ側では `#show: setup.with()` として適用する。
#let setup(
  sansfont: fonts.sans-font,
  sansfont-cjk: fonts.sans-font-cjk,
  monofont: fonts.mono-font,
  monofont-cjk: fonts.mono-font-cjk,
  margin-size: (top: 28mm, bottom: 24mm, left: 24mm, right: 24mm),
  columns: settings.columns,
  fig-separator: settings.fig-tab-separator,
  body,
) = {
  // PDFのタイトル、著者、日付、キーワードにconfig.yamlの値を反映する。
  let date = doc-date()

  set document(
    title: meta.title,
    author: meta.author,
    date: date,
    keywords: meta.keywords,
  )

  // A4ページ、余白、ヘッダー、フッターをまとめて設定する。
  // 表紙など個別ページは titlePage でこの設定を一時的に上書きする。
  set page(
    paper: "a4",
    numbering: "1",
    number-align: center,
    columns: columns,
    margin: margin-size,
    fill: dads-color.white,
    header: if settings.show-header [
      // ヘッダーは文書名と所属を薄いグレーで表示し、本文より目立たせない。
      #set text(font: (sansfont, sansfont-cjk), size: 8pt, fill: dads-color.gray-700)
      #grid(
        columns: (1fr, auto),
        gutter: 12pt,
        align(left)[#meta.title],
        align(right)[#meta-value("affiliation")],
      )
      #v(3pt)
      #rule(color: dads-color.gray-100, thickness: 0.5pt)
    ],
    footer: if settings.show-footer [
      // ページ番号は context が必要なので counter(page).display() を包んでいる。
      #set text(font: (sansfont, sansfont-cjk), size: 8pt, fill: dads-color.gray-700)
      #rule(color: dads-color.gray-100, thickness: 0.5pt)
      #v(3pt)
      #align(center)[#context counter(page).display()]
    ],
  )
  set footnote(numbering: "1 ")

  // 本文の基本タイポグラフィ。
  // 日本語文書として読みやすいようにサンセリフ、広めの行間、段落頭1em字下げにする。
  set text(font: (sansfont, sansfont-cjk), lang: "ja", size: 10pt, fill: dads-color.gray-900, weight: "regular")
  show strong: set text(font: (sansfont, sansfont-cjk), lang: "ja", weight: "bold")
  show raw: set text(font: (monofont, monofont-cjk), size: 9pt, fill: dads-color.gray-900)
  show link: set text(fill: dads-color.blue-900)
  set par(first-line-indent: (amount: 1em, all: true), leading: 0.7em, justify: false, spacing: 1.0em)

  // 箇条書きの設定
  set list(indent: 1.1em, body-indent: 0.75em, marker: ([\u{2022}], [-], [\u{002A}], [・]))
  set enum(indent: 1.1em, body-indent: 0.75em, numbering: "(1.a.i.A)")
  // 箇条書きの各項目は段落字下げしない。
  show list: set par(first-line-indent: 0pt)
  show enum: set par(first-line-indent: 0pt)

  // 参考文献の表示設定
  set bibliography(style: "sist02", full: true)

  // 見出しの設定。
  // レベル1はキーカラーと太い罫線、レベル2は細い罫線で階層を作る。
  set heading(numbering: settings.heading-numbering, bookmarked: true)
  show heading: it => {
    set text(font: (sansfont, sansfont-cjk), lang: "ja", weight: "bold", fill: dads-color.gray-900)
    set block(above: space-24, below: space-8)
    if it.level == 1 {
      v(space-24)
      block[
        #text(size: 18pt, fill: dads-color.blue-1100)[#it]
        #v(5pt)
        #rule(color: dads-color.blue-800, thickness: 1.2pt)
      ]
    } else if it.level == 2 {
      block[
        #text(size: 13pt)[#it]
        #v(3pt)
        #rule(color: dads-color.gray-200, thickness: 0.7pt)
      ]
    } else {
      text(size: 11pt, fill: dads-color.gray-800)[#it]
    }
  }
  show heading.where(level: 1): set text(size: 18pt)
  show heading.where(level: 2): set text(size: 13pt)
  show heading.where(level: 3): set text(size: 11pt)

  // 引用とコードブロック。
  // 色だけでなく左罫線や枠線で本文との差を作る。
  show quote: it => block(
    fill: dads-color.gray-50,
    stroke: (left: (paint: dads-color.blue-800, thickness: 3pt)),
    inset: (x: space-24, y: space-8),
    radius: 3pt,
    above: space-24,
    below: space-24,
  )[
    #set text(fill: dads-color.gray-800)
    #it
  ]
  show raw.where(block: true): it => block(
    fill: dads-color.gray-50,
    stroke: (paint: dads-color.gray-200, thickness: 0.6pt),
    inset: 9pt,
    radius: 3pt,
    width: 100%,
    above: space-24,
    below: space-24,
  )[
    #set text(font: (monofont, monofont-cjk), size: 8.5pt)
    #it
  ]

  // 図表の設定。
  // 図・表・リストのキャプション位置と接頭辞を日本語文書向けにそろえる。
  let tiered-numbering = (..nums) => {
      context {
        let chap = counter(heading).get().first() // 現在の章番号(1, 2...)を取得
        let fig = nums.pos().first()             // 図の連番(1, 2...)を取得
        [#chap.#fig]                             // "1.1" の形で出力
      }
    }
    
  show figure: set block(breakable: true)

  // 表はヘッダー行を薄い青背景にし、下罫線で行の境目を示す。
  set table(
    inset: (x: 7pt, y: 6pt),
    stroke: (x, y) => if y == 0 {
      (bottom: (paint: dads-color.blue-800, thickness: 1pt))
    } else {
      (bottom: (paint: dads-color.gray-100, thickness: 0.5pt))
    },
    fill: (x, y) => if y == 0 { dads-color.blue-50 } else { none },
    align: (x, y) => if y == 0 { left + horizon } else { left + horizon },
  )
  show figure.where(kind: table): set figure(placement: none, supplement: [表], numbering: "1.1")
  show figure.where(kind: table): set figure.caption(position: top, separator: [#fig-separator])

  show figure.where(kind: image): set figure(placement: none, supplement: [図], numbering: "1.1")
  show figure.where(kind: image): set figure.caption(position: bottom, separator: [#fig-separator])

  show figure.where(kind: "list"): set figure(placement: none, supplement: [リスト], numbering: "1.1")
  show figure.where(kind: "list"): set figure.caption(position: top, separator: [#fig-separator])

  body
}

// 文書冒頭の要約や注意書きに使う、淡い青の概要ボックス。
#let summaryBox(body, title: "概要") = {
  block(
    fill: dads-color.blue-50,
    stroke: (paint: dads-color.blue-300, thickness: 0.8pt),
    inset: space-16,
    radius: 4pt,
    width: 100%,
    above: space-24,
    below: space-24,
  )[
    #text(weight: "bold", fill: dads-color.blue-1100)[#title]
    #v(4pt)
    #body
  ]
}

// 用途別の注記ボックス。
// kindは info / success / warning / danger を想定する。
#let callout(body, kind: "info", title: none) = {
  let styles = (
    info: (bg: dads-color.blue-50, border: dads-color.blue-800, text: dads-color.blue-1100, label: "情報"),
    success: (bg: dads-color.green-50, border: dads-color.green-800, text: dads-color.green-800, label: "完了"),
    warning: (bg: dads-color.yellow-50, border: dads-color.yellow-900, text: dads-color.yellow-900, label: "注意"),
    danger: (bg: dads-color.red-50, border: dads-color.red-900, text: dads-color.red-900, label: "重要"),
  )
  let style = if kind in styles { styles.at(kind) } else { styles.info }
  let label = if title == none { style.label } else { title }
  block(
    fill: style.bg,
    stroke: (left: (paint: style.border, thickness: 4pt)),
    inset: (x: space-24, y: space-8),
    radius: 4pt,
    width: 100%,
    above: space-24,
    below: space-24,
  )[
    #text(weight: "bold", fill: style.text)[#label]
    #v(3pt)
    #body
  ]
}

// 数値や状態を横並びで見せるための小さな指標カード。
#let kpi(label, value, note: "") = {
  block(
    fill: dads-color.white,
    stroke: (paint: dads-color.gray-200, thickness: 0.7pt),
    inset: space-16,
    radius: 4pt,
    width: 100%,
  )[
    #text(size: 8pt, fill: dads-color.gray-700)[#label]
    #linebreak()
    #text(size: 20pt, weight: "bold", fill: dads-color.blue-1100)[#value]
    #if note != "" [
      #linebreak()
      #text(size: 8pt, fill: dads-color.gray-700)[#note]
    ]
  ]
}

// codelstのsourcecodeを、文書内の「リスト」として扱いやすくするラッパー。
// 呼び出し例: `#codeList([```typ ... ```], caption: [設定例])`
#let codeList(
  code,
  caption: none,
  lang: auto,
  numbers-side: "left",
  tab-size: 2,
  showrange: none,
  highlighted: (),
  numbers-start: auto,
) = {
  figure(
    sourcecode(
      lang: lang,
      numbers-side: numbers-side,
      tab-size: tab-size,
      showrange: showrange,
      highlighted: highlighted,
      numbers-start: numbers-start,
    )[#code],
    caption: caption,
    kind: "list",
  )
}

// Texのtitlepage環境に相当する関数。
// 通常のヘッダー・フッターを消し、表紙だけのページを作る。
#let titlePage(
  content,
  margin-size: (top: 27mm, bottom: 25mm, left: 20mm, right: 20mm),
  sansfont: fonts.sans-font,
  sansfont-cjk: fonts.sans-font-cjk,
) = {
  set page(numbering: none, margin: margin-size, columns: 1, header: none, footer: none)
  set text(font: (sansfont, sansfont-cjk), lang: "ja")
  content
  pagebreak()
  counter(page).update(1)
}

// デジタル庁デザインシステム風の表紙。
// 下部には作成者と所属を表示する。
#let docCover(
  body,
  title: meta.title,
  subtitle: meta-value("subtitle"),
  status: none,
) = {
  titlePage[
    #v(space-64)
    #if status != none [
      #text(size: 9pt, weight: "bold", fill: dads-color.blue-800)[#status]
      #v(space-24)
    ]
    #rule(color: dads-color.blue-800, thickness: 3pt)
    #v(space-24)
    #text(size: 30pt, weight: "bold", fill: dads-color.blue-1100)[#title]
    #v(space-8)
    #text(size: 14pt, fill: dads-color.gray-700)[#subtitle]
    #v(space-32)
    #body
    #v(1fr)
    #rule(color: dads-color.gray-200)
    #v(space-8)
    #grid(
      columns: (1fr, 1fr),
      gutter: space-24,
      [
        #text(size: 8pt, fill: dads-color.gray-700)[作成者]
        #linebreak()
        #text(size: 10pt)[#format-authors(meta.author)]
      ],
      [
        #text(size: 8pt, fill: dads-color.gray-700)[所属]
        #linebreak()
        #text(size: 10pt)[#meta-value("affiliation")]
      ],
    )
  ]
}


// 既存PDFをそのまま差し込むためのユーティリティ。
#let includePDF(
  file,
  margin-size: (top: 0mm, bottom: 0mm, left: 0mm, right: 0mm),
) = {
  set page(numbering: none, margin: margin-size, columns: 1)
  image(file, format: "pdf")
  pagebreak()
  counter(page).update(1)
}

// 外部ソースファイルを読み込み、リスト番号付きの図として掲載する。
#let includeSrc(
  filepath: "",
  lang: "plaintext",
  caption: none,
  numbers-side: "left",
) = {
  figure(
    sourcefile(read(filepath), lang: lang, numbers-side: numbers-side),
    caption: caption,
    kind: "list",
  )
}


// 手軽なまとめプリントを作りたいとき用の関数。
// 既存テンプレートとの互換用に残している簡易タイトル。
#let printTitle(
  title: "",
  title-font-ja: fonts.serif-font-cjk,
  title-font-en: fonts.serif-font,
  abstract: [],
  name-bar: false,
) = {
  set par()
  align(left)[
    #text(size: 20.74pt, font: (title-font-en, title-font-ja))[#title　　]
    #linebreak()
  ]
  abstract
  if name-bar == true {
    align(right)[
      #underline()[\u{3000}]
      年
      #underline()[\u{3000}\u{3000}]
      組
      #underline()[\u{3000}\u{3000}]
      番
      #let c = 0
      #while c < 10 {
        underline()[\u{3000}]
        c = c + 1
      }
    ]
  }
  v(5pt)
}

// 日本語強調やLaTeX風サイズ指定の互換ユーティリティ。
#let strong_ja(content) = {
  text(weight: "bold", lang: "ja", font: (fonts.sans-font, fonts.sans-font-cjk))[#content]
}

#let large(content) = {
  text(size: 12pt)[#content]
}

#let LARGE(content) = {
  text(size: 17.28pt)[#content]
}

#let Large(content) = {
  text(size: 14.4pt)[#content]
}

#let huge(content) = {
  text(size: 20.74pt)[#content]
}

#let Huge(content) = {
  text(size: 24.88pt)[#content]
}
