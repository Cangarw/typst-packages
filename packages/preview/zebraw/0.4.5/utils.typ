#import "states.typ": *

#let parse-zebraw-args(
  inset,
  background-color,
  highlight-color,
  comment-color,
  lang-color,
  comment-flag,
  lang,
  comment-font-args,
  lang-font-args,
  extend,
) = {
  let inset = if inset == none {
    inset-state.get()
  } else {
    inset-state.get() + inset
  }

  let background-color = if background-color == none {
    background-color-state.get()
  } else {
    background-color
  }

  let highlight-color = if highlight-color == none {
    highlight-color-state.get()
  } else {
    highlight-color
  }

  let comment-color = if comment-color == none {
    if comment-color-state.get() == none {
      highlight-color-state.get().lighten(50%)
    } else {
      comment-color-state.get()
    }
  } else {
    comment-color
  }

  let lang-color = if lang-color == none {
    if lang-color-state.get() == none { comment-color } else { lang-color-state.get() }
  } else {
    lang-color
  }

  let comment-flag = if comment-flag == none {
    comment-flag-state.get()
  } else {
    comment-flag
  }

  let lang = if lang == none {
    lang-state.get()
  } else {
    lang
  }

  let comment-font-args = if comment-font-args == none {
    comment-font-args-state.get()
  } else {
    comment-font-args-state.get() + comment-font-args
  }

  let lang-font-args = if lang-font-args == none {
    lang-font-args-state.get()
  } else {
    lang-font-args-state.get() + lang-font-args
  }

  let extend = if extend == none {
    extend-state.get()
  } else {
    extend
  }

  (
    inset: inset,
    background-color: background-color,
    highlight-color: highlight-color,
    comment-color: comment-color,
    lang-color: lang-color,
    comment-flag: comment-flag,
    lang: lang,
    comment-font-args: comment-font-args,
    lang-font-args: lang-font-args,
    extend: extend,
  )
}

#let tidy-highlight-lines(highlight-lines) = {
  let nums = ()
  let comments = (:)
  let lines = if type(highlight-lines) == int {
    (highlight-lines,)
  } else if type(highlight-lines) == array {
    highlight-lines
  }
  for line in lines {
    if type(line) == int {
      nums.push(line)
    } else if type(line) == array {
      nums.push(line.first())
      comments.insert(str(line.at(0)), line.at(1))
    } else if type(line) == dictionary {
      if not (line.keys().contains("header") or line.keys().contains("footer")) {
        nums.push(int(line.keys().first()))
      }
      comments += line
    }
  }
  (nums, comments)
}

#let curr-background-color(background-color, idx) = {
  let res = if type(background-color) == color {
    background-color
  } else if type(background-color) == array {
    background-color.at(calc.rem(idx, background-color.len()))
  }
  res
}

#let tidy-lines(
  lines,
  highlight-nums,
  comments,
  highlight-color,
  background-color,
  comment-color,
  comment-flag,
  comment-font-args,
  numbering-offset,
  is-html: false,
) = {
  lines
    .map(line => {
      let res = ()
      let body = if line.text == "" {
        linebreak()
      } else {
        line.body
      }
      if (type(highlight-nums) == array and highlight-nums.contains(line.number)) {
        let comment = if comments.keys().contains(str(line.number)) {
          (
            indent: if comment-flag != "" { line.text.split(regex("\S")).first() } else { none },
            comment-flag: comment-flag,
            body: text(..comment-font-args, comments.at(str(line.number))),
            fill: comment-color,
          )
        } else { none }
        res.push((
          number: line.number + numbering-offset,
          body: body,
          fill: highlight-color,
          // if it's html, the comment will be saved in this field
          comment: if not is-html { none } else { comment },
        ))
        // otherwise, we need to push the comment as a separate line
        if not is-html and comment != none {
          res.push((
            number: none,
            body: if comment != none {
              box(comment.indent)
              strong(text(ligatures: true, comment.comment-flag))
              h(0.35em, weak: true)
              comment.body
            } else { "" }, 
            fill: comment-color,
          ))
        }
      } else {
        let fill-color = curr-background-color(background-color, line.number)
        res.push((
          number: line.number + numbering-offset,
          body: body,
          fill: fill-color,
          comment: none,
        ))
      }
      res
    })
    .flatten()
}
