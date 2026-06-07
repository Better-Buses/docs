#import "common.typ": academicYear, authors, course, date, linkColor, mainColor, prjName, university

#let firstPage(title) = {
  show link: set text(fill: linkColor)
  set document(
    title: [#title - #course - #university],
    author: (
      authors.andreaS.name + " " + authors.andreaS.surname + " - Student Id " + authors.andreaS.stid,
      authors.andreaP.name + " " + authors.andreaP.surname + " - Student Id " + authors.andreaP.stid,
    ),
    description: [Report for the #course course at #university],
  )
  set page(
    margin: 0em,
  )


  grid(
    columns: (35%, 65%),
    [#rect(fill: mainColor, width: 100%, height: 105%)],
    [
      #align(top + center)[
        #v(5em)
        #text(weight: "bold", size: 3em)[#course]
      ]

      #align(center + horizon)[
        #text(size: 3em, weight: "bold")[#title]
        #v(-1em)
        #text(weight: "bold", size: 2em)[Report]
        #v(10em)
      ]


      #table(
        stroke: none,
        table.vline(x: 1, start: 0, stroke: mainColor),
        columns: (45%, auto),
        align: (x, y) => {
          if (x == 0) {
            right
          } else {
            left
          }
        },
        [*Team members*], [#authors.andreaS.name #authors.andreaS.surname (#authors.andreaS.stid)],
        [], [#authors.andreaP.name #authors.andreaP.surname (#authors.andreaP.stid)],
      )

      #align(bottom + center)[
        #text(weight: "bold")[#university - A.Y. #academicYear]
        #v(2em)
      ]
    ],
  )
}

#let tableOfContentPage(imageList: true, tableList: true) = {
  set page(
    margin: auto,
    footer: [
      #align(center)[#context [#counter(page).display("i")]] \
      #place(dx: -71pt, dy: -2pt)[#rect(height: 50%, width: 135%, stroke: none, fill: mainColor)]
    ],
  )

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    text(size: 1.2em)[*#it*]
  }
  outline(
    title: text(size: 1.2em)[#v(0.2em) Table of content #v(0.5em)],
  )

  if (imageList == true) {
    pagebreak()

    show outline: set text(weight: "thin")
    outline(
      title: text(size: 1.2em)[#v(0.2em) Images #v(0.5em)],
      target: figure.where(kind: image),
    )
  }

  if (tableList == true) {
    pagebreak()

    show outline: set text(weight: "thin")
    outline(
      title: text(size: 1.2em)[#v(0.2em) Tables #v(0.5em)],
      target: figure.where(kind: table),
    )
  }
}

#let config(
  body,
) = {
  show figure: set block(breakable: true)
  show link: it => underline(text(fill: linkColor)[#it])
  show ref: rf => underline(text(fill: mainColor)[#rf])

  set heading(numbering: "1.")

  show heading.where(level: 1): h => {
    set text(size: 1.5em)
    h
    v(0.2em)
  }
  show heading.where(level: 2): set text(size: 1.4em)
  show heading.where(level: 3): set text(size: 1.25em)
  show heading.where(level: 4): set text(size: 1.15em)

  set page(
    margin: (x: 50pt, y: auto),
    header: [

      #grid(
        columns: (33%, 33%, 33%),
        align: (x, y) => {
          if x == 0 {
            left + horizon
          } else if x == 1 {
            center + horizon
          } else {
            right + horizon
          }
        },
        [#prjName], [#course], [#date],
      )

      #line(length: 100%)


    ],
    footer: [
      #align(center)[#context [#counter(page).display("1 of 1", both: true)]] \
      #place(dx: -71pt, dy: -2pt)[#rect(height: 50%, width: 135%, stroke: none, fill: mainColor)]
    ],
  )

  body
}
