% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_tree.r
\name{plot_tree}
\alias{plot_tree}
\title{Create an igraph tree from a sentence}
\usage{
plot_tree(tokens, ..., sentence_i = 1, doc_id = NULL,
  sentence = NULL, annotation = NULL, pdf_file = NULL,
  allign_text = T, ignore_rel = NULL, all_lower = F,
  all_abbrev = NULL, textsize = 1, spacing = 1, use_color = T,
  max_curve = 0.3, palette = grDevices::terrain.colors)
}
\arguments{
\item{tokens}{A tokenIndex data.table, or any data.frame coercible with \link{as_tokenindex}.}

\item{...}{Optionally, select which columns to include as labels and how to present them. Can be quoted or unquoted names and expressions, using columns in the tokenIndex. For example, plot_tree(tokens, token, pos) will use the $token and $pos columns in tokens. You can also use expressions for easy controll of visulizations. For example: plot_tree(tokens, tolower(token), abbreviate(pos,1)). (note that abbreviate() is really usefull here)}

\item{sentence_i}{By default, plot_tree uses the first sentence (sentence_i = 1) in the data. sentence_i can be changed to select other sentences by position (the i-th unique sentence in the data). Note that sentence_i does not refer to the values in the sentence column (for this use the sentence argument together with doc_id)}

\item{doc_id}{Optionally, the document id can be specified. If so, sentence_i refers to the i-th sentence within the given document.}

\item{sentence}{Optionally, the sentence id can be specified (note that sentence_i refers to the position). If sentence is given, doc_id has to be given as well.}

\item{annotation}{Optionally, a column with an rsyntax annotation, to add boxes around the annotated nodes.}

\item{pdf_file}{Directly save the plot as a pdf file}

\item{allign_text}{If TRUE (default) allign text (the columns specified in ...) in a single horizontal line at the bottom, instead of following the different levels in the tree}

\item{ignore_rel}{Optionally, a character vector with relation names that will not be shown in the tree}

\item{all_lower}{If TRUE, make all text lowercase}

\item{all_abbrev}{If an integer, abbreviate all text, with the number being the target number of characters.}

\item{textsize}{A number to manually change the textsize. The function tries to set a suitable textsize for the plotting device, but if this goes wrong and now everything is broken and sad, you can multiply the textsize with the given number.}

\item{spacing}{A number for scaling the distance between words (between 0 and infinity)}

\item{use_color}{If true, use colors}

\item{max_curve}{A number for controlling the allowed amount of curve in the edges.}

\item{palette}{A function for creating a vector of n contiguous colors. See ?terrain.colors for standard functions and documentation}
}
\value{
an igraph graph
}
\description{
Create an igraph tree from a token_index (\link{as_tokenindex}) or a data.frame that can be coerced to a tokenindex.

By default, all columns in the data are included as labels. This can be changes by using the ... argument.
}
