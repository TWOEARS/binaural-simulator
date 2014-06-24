/**
 * @page faq mtoc++ FAQ
 *
 * @section faq_general General issues with mtoc++
 *
 * @par How do I generate LaTeX output?
 * LaTeX is supported by doxygen and partly by mtoc++. Partly to that extend that, the mtocpp_post postprocessor
 * is designed to correct the format of the produced HTML, but not the LaTeX output (very different!).
 * It is run nontheless, but will not produce such a nice output as HTML pages.
 * However, use the MatlabDocMaker with the option ('latex',true) to generate LaTeX output.
 * If you configure Doxygen yourself (see @ref tools_direct) with LaTeX output, latex will complain about the missing "latexextras.sty", which are
 * temporarily created by the DocMaker at creation time. Remove the inclusion (or setup your own latex inclusion file) to get that right.
 *
 * @par Can mtoc++ handle varargin arguments with inputParser? (2013-07-18, Thanks to Alexander Pfeiffer, EADS)
 * Yes, mtoc++ can understand the inputParser syntax and will generally create an extra "parameter description" part to the parameter
 * list. If you want to add specific information or a comment in general about the extra arguments, you can use
 * the syntax @code varargin: <some comment> @endcode to make mtoc++ add a comment to the optional argument list.
 * See the examples.Class class for a demo function.
 *
 * @par Where should i put the configuration files and output directory?
 * Even though it is no requirement regarding mtoc++, it is good style/project management if you have a root folder
 * containing all project-related things in a flat hierarchy, meaning you have a "src" folder with sources and a separate
 * one "docs" containing the documentation. however, the configuration files (tools/config) should be copied
 * into the source folder (e.g. "src/docs_config") for each project to keep things together and versioned, if e.g. GIT or SVN is used.
 *
 * @section faq_unix UNIX-related questions
 *
 * @section faq_windows Windows-related questions
 *
 * @section todo_collection ToDo-Collection
 * @todo disable mtoc++ processing in @verbatim environments (at least via switch in mtocpp.conf)
 * @todo finish enum support (simple list is working, but mtocpp breaks if comments are present)
 *
 */
