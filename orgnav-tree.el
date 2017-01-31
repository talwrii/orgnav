;;; orgnav-tree.el --- Orgnav functions to interact with trees

;; Copyright (C) 2016 Tal Wrii

;; Author: Tal Wrii (talwrii@gmail.com)
;; URL: github.com/talwrii/orgnav

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:
;;

;;; Code:

(require 'org)
(require 'orgnav-hack)

(defun orgnav-tree-get-parent (point)
  "Get the parent of the node at POINT."
  (orgnav-tree-get-ancestor point 1))

(defun orgnav-tree-get-ancestor (point levels)
  "Get the ancestor of the node at POINT, LEVELS levels up."
  (save-excursion
    (goto-char point)
    (condition-case nil
        (progn
          (outline-up-heading levels t)
          (point))
      (error nil))))

(defun orgnav-tree-get-heading (buffer point)
  "Get the heading of an org element in BUFFER at POINT."
  (with-current-buffer buffer
    (save-excursion
      (setq point (or point (point)))
      (progn
        (goto-char point)
        (substring-no-properties (org-get-heading))))))

(defun orgnav-tree-get-descendants (tree &optional depth)
  "Get the positions of all the headings under the tree at TREE."
  (interactive)
  (let ((result))
    (save-excursion
      (if (not (null tree)) (goto-char tree))
      (if
          (null tree)
          (orgnav-tree-buffer-map (lambda () (add-to-list 'result (point) 't)) depth)
        (orgnav-tree-tree-map (lambda () (add-to-list 'result (point) 't)) tree depth)))
    result))

(defun orgnav-tree-rename (point name)
  "Rename the node at POINT to NAME."
  (let (new-heading)
    (save-excursion
      (goto-char point)
      (setq new-heading
            (concat (s-repeat (org-outline-level) "*") " " name))

      (beginning-of-line)
      (kill-line)
      (insert new-heading))))

(defun orgnav-tree-tree-map (fun node depth)
  "Call FUN at NODE and all its descendants up to depth DEPTH."
  (save-excursion
    (goto-char node)
    (funcall fun)
    (let ((child (orgnav-tree--first-child node)))
      (when child (orgnav-tree--forest-map fun child (- depth 1))))))

(defun orgnav-tree-buffer-map (fun depth)
  "Call FUN at all nodes in the current buffer up to a depth DEPTH"
  (save-excursion
    (orgnav-tree--goto-buffer-first)
    (orgnav-tree--forest-map fun (point) (- depth 1))))

(defun orgnav-tree--goto-buffer-first ()
  (goto-char (point-min))
  (when (not (outline-on-heading-p 't))
           (outline-next-heading)))

(defun orgnav-tree--forest-map (fun node depth)
  ;;; Adapted from org-map-region in org (GPL)
  "Call FUN for NODE, its siblings and their descendants up to DEPTH."
  (let ((org-ignore-region t) (finished nil))
    (when (>= depth 0)
      (save-excursion
        (goto-char node)
        (while (not finished)
          (funcall fun)
          (when (> depth 0)
            (let ((child (orgnav-tree--first-child (point))))
              (when child (orgnav-tree--forest-map fun child (- depth 1)))))
          (condition-case nil
              (orgnav-hack-outline-forward-same-level 1)
            (error (setq finished 't))))))))

(defun orgnav-tree-ancestors (&optional point)
  "Find the ancestors of the current org node (or the one at POINT)."
  (save-excursion
    (when point (goto-char point))
    (outline-back-to-heading 't)
    (cons (point) (orgnav-tree--ancestors-rec))))

(defun orgnav-tree--ancestors-rec ()
  "Convenience function used by `orgnav-tree-ancestors'."
  (if
      (condition-case nil
          (progn
            (outline-up-heading 1 't)
            't)
        (error nil))
      (cons (point) (orgnav-tree--ancestors-rec))
    nil))

(defun orgnav-tree--first-child (node)
  (interactive)
  (save-excursion
    (goto-char node)
    (org-back-to-heading 't)
    (let ((level (org-outline-level)))
      (outline-next-heading)
      (if (<= (org-outline-level) level) nil
        (point)))))


(provide 'orgnav-tree)
;;; orgnav-tree.el ends here
