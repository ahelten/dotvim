hi link cCommentUnderscore cComment
syn match cCommentUnderscore display '\k\+_\w\+'
syn cluster cCommentGroup add=cCommentUnderscore
