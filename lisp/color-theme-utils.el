;;; color-theme-utils.el --- Color theme utils  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  tangxinfa

;; Author: tangxinfa <tangxinfa@gmail.com>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Export color theme definitions for other applications to use.

;;; Code:


;; Support hook after theme load and unload.
(defvar after-load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")
(defadvice load-theme (after run-after-load-theme-hook activate)
  "Run `after-load-theme-hook'."
  (run-hooks 'after-load-theme-hook))
(defvar after-disable-theme-hook nil
  "Hook run after a color theme is disabled using `disable-theme'.")
(defadvice disable-theme (after run-after-disable-theme-hook activate)
  "Run `after-disable-theme-hook'."
  (run-hooks 'after-disable-theme-hook))

;; Disable any loaded themes before enabling a new theme.
(defadvice load-theme (before disable-before-load)
  "Disable any loaded themes before enabling a new theme.
This prevents overlapping themes; something I would rarely want."
  (dolist (theme custom-enabled-themes)
    (disable-theme theme)))
(ad-activate 'load-theme)

;; Export color theme definitions into files.
(defvar color-theme-utils-xresources-file "~/.Xresources"
  "Xresources file to save emacs color theme definitions.")
(defvar color-theme-utils-rasi-file "~/.emacs.d/.rasi"
  "Rasi file to save emacs color theme definitions.")

(defun color-theme-utils-xresources-save ()
  (let ((comments "! Generate by color-theme-utils.el"))
    (with-temp-buffer
      (insert-file-contents color-theme-utils-xresources-file)
      (flush-lines "^ *Emacs\\.")
      (flush-lines comments)
      (goto-char (point-max))
      (insert (format "\
%s
Emacs.Default.background:              %s\n\
Emacs.Default.foreground:              %s\n\
Emacs.ModeLine.background:             %s\n\
Emacs.ModeLine.foreground:             %s\n\
Emacs.ModeLine.underline:              %s\n\
Emacs.ModeLineHighlight.foreground:    %s\n\
Emacs.ModeLineInactive.background:     %s\n\
Emacs.ModeLineInactive.foreground:     %s\n\
Emacs.ModeLineInactive.underline:      %s\n\
Emacs.Region.background:               %s\n\
Emacs.Region.foreground:               %s\n\
Emacs.Fringe.background:               %s\n\
Emacs.Fringe.foreground:               %s\n\
Emacs.VerticalBorder.background:       %s\n\
Emacs.VerticalBorder.foreground:       %s\n\
Emacs.Menu.background:                 %s\n\
Emacs.Menu.foreground:                 %s\n\
Emacs.Tooltip.background:              %s\n\
Emacs.Tooltip.foreground:              %s\n\
Emacs.Isearch.background:              %s\n\
Emacs.Isearch.foreground:              %s\n\
Emacs.Highlight.background:            %s\n\
Emacs.Shadow.foreground:               %s\n\
Emacs.Cursor.background:               %s\n\
Emacs.Cursor.foreground:               %s\n\
Emacs.Keyword.foreground:              %s\n\
Emacs.Warning.foreground:              %s\n\
Emacs.Error.foreground:                %s\n"
                      comments
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (face-background 'default nil t))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (face-foreground 'default nil t))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'mode-line nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'mode-line nil t) (face-foreground 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-attribute-specified-or (face-attribute 'mode-line :underline nil t) nil) (face-background 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'mode-line-highlight nil t) (face-foreground 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'mode-line-inactive nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'mode-line-inactive nil t) (face-foreground 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-attribute-specified-or (face-attribute 'mode-line-inactive :underline nil t) nil) (face-background 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'region nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'region nil t) (face-foreground 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'fringe nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'fringe nil t) (face-foreground 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'vertical-border nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'vertical-border nil t) (face-foreground 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'menu nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'menu nil t) (face-foreground 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'tooltip nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'tooltip nil t) (face-foreground 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'isearch nil t) (face-background 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'isearch nil t) (face-foreground 'default  nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'highlight nil t) (face-background 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'shadow nil t) (face-foreground 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-background 'cursor nil t) (face-background 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'cursor nil t) (face-background 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'font-lock-keyword-face nil t) (face-foreground 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'warning nil t) (face-foreground 'default nil t)))
                                                       (list 2)))
                      (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                        (or (face-foreground 'error nil t) (face-foreground 'default nil t)))
                                                       (list 2)))))
      (write-file color-theme-utils-xresources-file))))

(defun color-theme-utils-rasi-save ()
  (with-temp-file color-theme-utils-rasi-file
    (insert (format "* {\n\
    emacs-default-background:              %s;\n\
    emacs-default-foreground:              %s;\n\
    emacs-modeline-background:             %s;\n\
    emacs-modeline-foreground:             %s;\n\
    emacs-modeline-underline:              %s;\n\
    emacs-modeline-highlight-foreground:   %s;\n\
    emacs-modeline-inactive-background:    %s;\n\
    emacs-modeline-inactive-foreground:    %s;\n\
    emacs-modeline-inactive-underline:     %s;\n\
    emacs-region-background:               %s;\n\
    emacs-region-foreground:               %s;\n\
    emacs-fringe-background:               %s;\n\
    emacs-fringe-foreground:               %s;\n\
    emacs-vertical-border-background:      %s;\n\
    emacs-vertical-border-foreground:      %s;\n\
    emacs-menu-background:                 %s;\n\
    emacs-menu-foreground:                 %s;\n\
    emacs-tooltip-background:              %s;\n\
    emacs-tooltip-foreground:              %s;\n\
    emacs-isearch-background:              %s;\n\
    emacs-isearch-foreground:              %s;\n\
    emacs-highlight-background:            %s;\n\
    emacs-shadow-foreground:               %s;\n\
    emacs-cursor-background:               %s;\n\
    emacs-cursor-foreground:               %s;\n\
    emacs-keyword-foreground:              %s;\n\
    emacs-warning-foreground:              %s;\n\
    emacs-error-foreground:                %s;\n\
}"
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (face-background 'default nil t))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (face-foreground 'default nil t))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'mode-line nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'mode-line nil t) (face-foreground 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-attribute-specified-or (face-attribute 'mode-line :underline nil t) nil) (face-background 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'mode-line-highlight nil t) (face-foreground 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'mode-line-inactive nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'mode-line-inactive nil t) (face-foreground 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-attribute-specified-or (face-attribute 'mode-line-inactive :underline nil t) nil) (face-background 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'region nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'region nil t) (face-foreground 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'fringe nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'fringe nil t) (face-foreground 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'vertical-border nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'vertical-border nil t) (face-foreground 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'menu nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'menu nil t) (face-foreground 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'tooltip nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'tooltip nil t) (face-foreground 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'isearch nil t) (face-background 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'isearch nil t) (face-foreground 'default  nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'highlight nil t) (face-background 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'shadow nil t) (face-foreground 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-background 'cursor nil t) (face-background 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'cursor nil t) (face-background 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'font-lock-keyword-face nil t) (face-foreground 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'warning nil t) (face-foreground 'default nil t)))
                                                     (list 2)))
                    (apply #'color-rgb-to-hex (nconc (color-name-to-rgb
                                                      (or (face-foreground 'error nil t) (face-foreground 'default nil t)))
                                                     (list 2)))))))

(defun color-theme-utils-export ()
  "Export currrent color theme definitions."
  (interactive)
  (message "Emacs color theme %s"
           (propertize (symbol-name (or (car custom-enabled-themes) 'default-theme)) 'face 'font-lock-variable-name-face))
  (color-theme-utils-xresources-save)
  (color-theme-utils-rasi-save)
  (call-process-shell-command "i3-msg exec ~/bin/desktop-on-change"))

(add-hook 'after-load-theme-hook #'color-theme-utils-export)

(provide 'color-theme-utils)
;;; color-theme-utils.el ends here