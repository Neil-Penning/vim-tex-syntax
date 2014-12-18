" Vim simple TeX syntax file
" Maintainer:	GI <gi1242+vim@nospam.com> (replace nospam with gmail)
" Created:	Tue 16 Dec 2014 03:45:10 PM IST
" Last Changed:	Thu 18 Dec 2014 12:54:00 PM IST
" Version:	0.1
"
" Description:
"   Highlight LaTeX documents without the ridiculous amount of complexity used
"   by the default tex.vim syntax file.

" Load control {{{1
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Spell {{{1
syn spell toplevel

" All top level groups should be added manually to these groups
syn cluster TopNoSpell	remove=@Spell
syn cluster TopSpell	add=@Spell

" Helper function to create top level syntax groups
function! s:syn_top( qargs, action, groupname, ... )
    exe 'syn cluster TopNoSpell add='.a:groupname
    exe 'syn cluster TopSpell add='.a:groupname
    exe 'syn' a:qargs
endfunction
command! -nargs=+ Tsy :call s:syn_top( <q-args>, <f-args> )

" {{{1 TeX Commands
" Leading backslash for commands. Do this first, so it can be overridden
Tsy match texCommand '\v\\' nextgroup=@texCommands
syn cluster texCommands
	    \ contains=texSectionCommands,texSpecialCommands,texGenericCommand

" Generic commands {{{2
syn match texGenericCommand contained '\v[a-zA-Z@]+\*?'
	    \ nextgroup=texArgsGeneric skipwhite skipempty

" Highlight spelling in arguments. Don't color arguments, but mark delimiters.
syn region texArgsGeneric contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsGeneric skipwhite skipempty
	    \ contains=@TopSpell,texTokens
syn region texArgsGeneric contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsGeneric skipwhite skipempty
	    \ contains=@TopSpell,texTokens


" Section commands {{{2
syn keyword texSectionCommands contained
	    \ nextgroup=texStarSection,texArgsSection
	    \ skipwhite skipempty
	    \ part chapter section subsection subsubsection paragraph subparagraph

" Section command arguments. (Spell checked, highlighted as PreProc)
syn match texStarSection contained '\*'
	    \ nextgroup=texArgsSection skipwhite skipempty
syn region texArgsSection contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsSection skipwhite skipempty
	    \ contains=@TopSpell
syn region texArgsSection contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsSection skipwhite skipempty
	    \ contains=@TopSpell

" Special commands {{{2
syn keyword texSpecialCommands contained
	    \ nextgroup=@texArgsSpecial,texStarSpecial skipwhite skipempty
	    \ usepackage RequirePackage documentclass
	    \ includegraphics setlength eqref ref cite cites pageref bibliography
	    \ bibliographystyle notcite label

" Color and don't spell arguments for Special commands
syn match texStarSpecial contained '\*' nextgroup=@texArgsSpecial skipwhite skipempty
syn cluster texArgsSpecial contains=texArgsSpecialOpt,texArgsSpecialReq
syn region texArgsSpecialOpt contained matchgroup=texArgDelims
	    \ start='\[' end='\]'
	    \ nextgroup=@texArgsSpecial skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsSpecialReq contained matchgroup=texArgDelims
	    \ start='{' end='}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpecial skipwhite skipempty

" {{{1 Preamble
" Should be defined after commands
Tsy region texPreamble fold
	    \ start='\v%(\\documentclass)@=' end='\v(\\begin\{document\})@='
	    \ contains=@texPreambleStuff

syn cluster texPreambleStuff contains=texComment,texPreambleCommand

syn match texPreambleCommand contained '\\'
	    \ nextgroup=texPreambleGenCommand,texSpecialCommands

" Should be done before texSpecialCommands
syn match texPreambleGenCommand contained '\v[a-zA-Z@]+\*?'
	    \ nextgroup=texArgsNoSpell skipwhite skipempty

" Don't color arguments, but mark delimiters. Don't spell.
syn region texArgsNoSpell contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsNoSpell skipwhite skipempty
	    \ contains=@TopNoSpell,texTokens
syn region texArgsNoSpell contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsNoSpell skipwhite skipempty
	    \ contains=@TopNoSpell,texTokens

" Math {{{1
Tsy region texMath start='\$' end='\$' contains=@texAllowedInMath
Tsy region texMath start='\$\$' end='\$\$' contains=@texAllowedInMath
Tsy region texMath start='\\(' end='\\)' contains=@texAllowedInMath

syn cluster texAllowedInMath
	    \ contains=texSpecialChars,texMathCommand,texMathEnv,texComment

" Math commands with math arguments.
syn match texMathCommand contained '\\' nextgroup=texMathCommands
syn match texMathCommands '\v[a-zA-Z]+\*?' contained
	    \ nextgroup=texMathMArg skipwhite skipempty
syn region texMathMArg contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texMathMArg skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen
syn region texMathMArg contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texMathMArg skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen

syn keyword texMathCommands contained
	    \ text textit textbf parbox raisebox mbox operatorname
	    \ nextgroup=@texMathTArgs,texStarMathText skipwhite skipempty
syn match texStarMathText contained '\*' nextgroup=@texMathTArgs skipwhite skipempty
syn cluster texMathTArgs contains=texArgsMathTextOpt,texArgsMathTextReq
syn region texArgsMathTextOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texMathTArgs skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsMathTextReq contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=@texMathTArgs skipwhite skipempty
	    \ contains=TOP

" Environments {{{1
Tsy region texEnv transparent
	    \ matchgroup=texArgsSection
	    \ start='\v\\begin\{\z([a-zA-Z]+\*?)\}'
	    \ end='\v\\end\{\z1\}'
	    \ contains=@TopSpell

Tsy region texArgsEnvReq
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{[a-zA-Z]+\*?\}\s*)@<=\{' end='}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpecial skipwhite skipempty
Tsy region texArgsEnvOpt
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{[a-zA-Z]+\*?\})@<=\[' end=']'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpecial skipwhite skipempty

" Math environments
let math_env_names = []
command! -nargs=+ MathEnvs let math_env_names += [<f-args>]
MathEnvs align alignat displaymath eqnarray equation gather IEEEeqnarray
	    \ multline subequations xalignat xxalignat
delc MathEnvs

let start_re = '\v\\begin\{\z(%(' . join( math_env_names, '|' ) . ')\*?)\}'
exe 'Tsy region texEnvMath matchgroup=texMath'
	    \ 'start="'.start_re.'" end="\v\\end\{\z1\}" contains=@texAllowedInMath'

syn region texMathEnv transparent contained
	    \ matchgroup=texArgsSection
	    \ start='\v\\begin\{\z([a-zA-Z]+\*?)\}'
	    \ end='\v\\end\{\z1\}'
	    \ contains=@texAllowedInMath

" Unmatched end environments
Tsy match texEnvEndError '\\end\>'

" Document will likely be longer than sync minlines; don't match a missing end
" as an error.
Tsy match texEnvEndDoc '\v\\end\{document\}'

" Misc TeX Constructs. {{{1
" {{{2 Misc TeX dimensions
Tsy match texDimen '\v-?%(\.[0-9]+|([0-9]+(\.[0-9]+)?))%(pt|pc|bp|in|cm|mm|dd|cc|sp|ex|em)>'
"syn keyword texUnits contained pt pc bp in cm mm dd cc sp ex em

" {{{2 TeX macro tokens
Tsy match texTokenError '#[0-9]'
syn match texTokens contained '#[0-9]'

" TeX backslashed special characters
Tsy match texSpecialChars '\v\\%(\\%(\[[0-9]\])?|[$&#\'":`]|[ijv]>)'

" {{{1 TeX Comments
Tsy match  texComment	'%\s.*$' contains=@Spell
Tsy match  texComment	'%\S.*$'
Tsy region texComment	start='\\iffalse\>'	end='\\else\>'  end='\\fi\>' contains=texComment,texNestedIf matchgroup=texComment
syn region texNestedIf contained transparent start='\\if\%(false\|true\)\@!\w\{2,}' skip='\\else\>' end='\\fi\>' contains=texNestedIf


" {{{1 Folding

" Fold by sections / subsections
Tsy region texSectionFold   transparent fold keepend
	    \ start='\v%(%(\\begin\{document\}.*$\n)@<=^|\\section)'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\section))@='
	    \ end='\v\n%(\s*(\\bibliographystyle|\\begin\{thebibliography\}))@='
	    \ end='%endsection'

Tsy region texSubsectionFold transparent fold keepend
	    \ start='\v\\subsection'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\%(sub)?section))@='
	    \ end='\v\n%(\s*(\\bibliographystyle|\\begin\{thebibliography\}))@='
	    \ end='\v\%end%(sub)?section'

Tsy region texSubsubsectionFold transparent fold keepend
	    \ start='\v\\subsubsection'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\%(sub)*section))@='
	    \ end='\v\n%(\s*(\\bibliographystyle|\\begin\{thebibliography\}))@='
	    \ end='\v\%end%(sub)*section'

" BibTeX bibliography.
Tsy region texBibFold transparent fold keepend
	    \ start='\v\\bibliographystyle'
	    \ end='\v\n%(\s*\\end\{document\})@='

" Fold environments (theorems, etc.)
let fold_envs = []
command! -nargs=+ FoldEnvs let fold_envs += [<f-args>]
FoldEnvs theorem proof lemma proposition corollary remark thebibliography
delc FoldEnvs

let start_re = '\v\\begin\{\z(%(' . join( fold_envs, '|' ) . ')\*?)\}'
exe 'Tsy region texEnvFold transparent fold keepend'
	    \ 'start="'.start_re.'" end="\v\\end\{\z1\}"'

" Comment markers. Only %{{{{ and %}}}} are supported. No number versions
" Use four braces (instead of 3) to avoid confusion with existing fold
" markers.
Tsy region texCommendFold transparent fold keepend extend
	    \ start='\v\%.*\{{4}'
	    \ end='\v\%.*\}{4}'

" Synchronization {{{1
"syn sync maxlines=200
syn sync minlines=50
syn sync match texSync		grouphere NONE		'\v\\(sub)*section>'

" Sync items from the official VIM syntax file. Matching one of these might
" break the end proof environment, since proofs can be quite long.
"syn sync match texSync		groupthere NONE		'\\end{abstract}'
"syn sync match texSync		groupthere NONE		'\\end{center}'
"syn sync match texSync		groupthere NONE		'\\end{description}'
"syn sync match texSync		groupthere NONE		'\\end{enumerate}'
"syn sync match texSync		groupthere NONE		'\\end{itemize}'
"syn sync match texSync		groupthere NONE		'\\end{table}'
"syn sync match texSync		groupthere NONE		'\\end{tabular}'

" End math zones.
"let math_end_re = '\v\\end\{%(' . join( math_env_names, '|' ) . ')\*?\}'
"exe 'syn sync match texSync groupthere NONE' "'".math_end_re."'"

" {{{1 Highlighting groups
hi def link texMath		    Type
hi def link texCommand		    Statement

hi def link texSectionCommands	    texCommand
hi def link texSpecialCommands	    texCommand
hi def link texGenericCommand	    texCommand
hi def link texStarSpecial	    texSpecialCommands

hi def link texPreambleCommand	    texCommand
hi def link texPreambleGenCommand   texPreambleCommand

hi def link texArgSep		    Special
hi def link texDimen		    Number
hi def link texTokens		    Type
hi def link texTokenError	    Error
hi def link texSpecialChars	    Special

hi def link texArgDelims	    Special
hi def link texArgsSpecialOpt	    Constant
hi def link texArgsSpecialReq	    Type

hi def link texStarSection	    texSectionCommands
hi def link texArgsSection	    PreProc

hi def link texMathCommand	    texCommand
hi def link texMathCommands	    texCommand
hi def link texArgsMathTextOpt	    texArgsSpecialOpt
hi def link texArgsMathTextReq	    Normal
hi def link texStarMathText	    texMathCommand

hi def link texEnvMath		    texMath
hi def link texArgsEnvReq	    texArgsSpecialReq
hi def link texArgsEnvOpt	    texArgsSpecialOpt

hi def link texEnvEndError	    Error
hi def link texEnvEndDoc	    texArgsSection

hi def link texComment		    Comment

" {{{1 Cleanup
let   b:current_syntax = "tex"
let &cpo               = s:cpo_save

unlet s:cpo_save math_env_names start_re

