# Nushell Config File

let theme = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: { || if $in { 'light_cyan' } else { 'light_gray' } }
    int: white
    filesize: {|e|
      if $e == 0b {
        'white'
      } else if $e < 1mb {
        'cyan'
      } else { 'blue' }
    }
    duration: white
    date: { || (date now) - $in |
      if $in < 1hr {
        'light_red'
      } else if $in < 6hr {
        'light_orange'
      } else if $in < 1day {
        'yellow'
      } else if $in < 3day {
        'light_green'
      } else if $in < 1wk {
        'green'
      } else if $in < 6wk {
        'blue'
      } else if $in < 52wk {
        'gray'
      } else { 'dark_gray' }
    }    
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray

    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_blue
    shape_custom: green
    shape_datetime: blue_bold
    shape_directory: blue
    shape_external: blue
    shape_externalarg: green_bold
    shape_filepath: blue
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: red_underline
    shape_globpattern: blue_bold
    shape_int: purple_bold
    shape_internalcall: blue_bold
    shape_list: blue_bold
    shape_literal: blue
    shape_matching_brackets: { attr: u }
    shape_nothing: light_blue
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: blue_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: blue_bold
    shape_table: blue_bold
    shape_variable: purple
}

let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"' | str trim | split row "\n" | each { |line| $line | split column "\t" value description } | flatten
}

let-env config = {
 
  ls: {
    use_ls_colors: true
    clickable_links: false
  }

  cd: {
    abbreviations: true
  }

  table: {
    mode: rounded
    index_mode: auto
    trim: {
      methodology: wrapping
      wrapping_try_keep_words: true
      truncating_suffix: "..."
    }
  }

  history: {
    max_size: 10000
    sync_on_enter: true
    file_format: "plaintext"
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
      enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
      max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
      completer: $fish_completer
    }
  }

  filesize: {
    metric: true
    format: "auto"
  }

  cursor_shape: {
    emacs: line
    vi_insert: block
    vi_normal: underscore
  }

  color_config: $theme
  use_grid_icons: true
  footer_mode: "25" # always, never, number_of_rows, auto
  float_precision: 2
  use_ansi_coloring: true
  edit_mode: emacs
  shell_integration: true
  show_banner: false

  hooks: {
    display_output: { ||
      if (term size).columns >= 100 { table -e } else { table }
    }
  }

  menus: [
      {
        name: completion_menu
        only_buffer_difference: false
        marker: ""
        type: {
            layout: columnar
            columns: 4
            col_padding: 2
        }
        style: {
            text: yellow
            selected_text: blue_reverse
            description_text: blue
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 20
        }
        style: {
            text: yellow
            selected_text: blue_reverse
            description_text: blue
        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: yellow
            selected_text: blue_reverse
            description_text: blue
        }
      }
      {
        name: vars_menu
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.vars
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
        }
      }
  ]

  keybindings: [
    # Default keybindings
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
      event: { send: menuprevious }
    }
    {
      name: history_menu
      modifier: control
      keycode: char_r
      mode: emacs
      event: { send: menu name: history_menu }
    }
    {
      name: yank
      modifier: control
      keycode: char_y
      mode: emacs
      event: {
        until: [
          {edit: pastecutbufferafter}
        ]
      }
    }
    {
      name: unix-line-discard
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cutfromlinestart}
        ]
      }
    }
    {
      name: kill-line
      modifier: control
      keycode: char_k
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cuttolineend}
        ]
      }
    }
    # Keybindings used to trigger the user defined menus
    {
      name: vars_menu
      modifier: alt
      keycode: char_o
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
  ]
}

# Use zoxide
source ~/.cache/zoxide/init.nu

# Use starship
source ~/.cache/starship/init.nu

# Source aliases
source ~/.config/nushell/aliases.nu
use aliases *

# Git aliases and completion
source ~/.config/nushell/git.nu
use git *

# Helix aliases and functions
source ~/.config/nushell/helix.nu
use helix *

# Source kubectl aliases and functions
source ~/.config/nushell/kube.nu
use kube *

# Source websearch aliases and functions
source ~/.config/nushell/search.nu
use search *

# Custom completions
module completions {}
use completions *

# Open ZelliJ session if not inside one
if ($env | columns | where $it == ZELLIJ | is-empty) {
  zellij attach -c thomas
}
