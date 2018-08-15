CORENLP_SAY_VERBS = c("tell", "show", " acknowledge", "admit", "affirm", "allege", "announce", "assert", "attest", "avow", "claim", "comment", "concede", "confirm", "declare", "deny", "exclaim", "insist", "mention", "note", "proclaim", "remark", "report", "say", "speak", "state", "suggest", "talk", "tell", "write", "add")
CORENLP_QUOTE_RELS=  c("ccomp", "dep", "parataxis", "dobj", "nsubjpass", "advcl")
CORENLP_SUBJECT_RELS = c('su', 'nsubj', 'agent', 'nmod:agent') 

CORENLP_VERB_POS = c('MD','VB','VBD','VBG','VBN','VBP','VBZ')
CORENLP_NOUN_POS = c('NN','NNS','FW')
CORENLP_ADJ_POS = c('JJ','JJR','JJS','WRB')
CORENLP_PREP_POS = 'IN'
CORENLP_CONJ_POS = 'LS'
CORENLP_PNOUN_POS = c('NNS','NNPS')
CORENLP_DETER_POS = c('PDT','DT','WDT')
CORENLP_ADVERB_POS = c('RB','RBR','RBS')

#' Returns a list with the quote queries for CoreNLP
#'
#' @return A list with rynstax queries, as created with \link{tquery}
#' @export
corenlp_quote_queries <- function(say_verbs=CORENLP_SAY_VERBS) {
  
  subject_relations = c('su', 'nsubj', 'agent', 'nmod:agent') 
  
  direct = tquery(lemma = CORENLP_SAY_VERBS, save='quote', 
                         children(relation=c('su', 'nsubj', 'agent', 'nmod:agent'), save='source'))
  
  nosrc = tquery(POS='VB*', save='quote',
                 children(relation= c('su', 'nsubj', 'agent', 'nmod:agent'), save='source'),
                 children(lemma = CORENLP_SAY_VERBS, relation='xcomp',
                          children(relation=c("ccomp", "dep", "parataxis", "dobj", "nsubjpass", "advcl"), save='quote')))
  
  according = tquery(save='quote',
                     children(relation='nmod:according_to', save='source'))
  
  list(direct=direct, nosrc=nosrc, according=according)
}
  


#' Get clauses from tokens parsed by coreNLP
#'
#' @param tokens     a token list data frame
#' @param block      Optionally, .G_ID's to exclude from search. Can also be a data.table with nodes, as returned by
#'                   find_nodes or get_quotes_alpino
#'
#' @return a data.table with nodes (as .G_ID) for id, subject and predicate
get_clauses <- function(tokens, quotes=NULL) {
  tokens = as_tokenindex(tokens_corenlp)
  block = if (is.null(quotes)) NULL else unique(quotes$id)
  
  clauses = find_nodes(tokens, pos1='V', id__not_in=block, 
                       children=list(subject = list(relation__in=CORENLP_SUBJECT_RELS)))
  colnames(clauses) = c('predicate', 'subject')
  
  # add passives without agent and parataxis verbs without subject
  passives = tokens$parent[tokens$relation == "nsubjpass"]
  parataxis = find_nodes(tokens, relation="parataxis", children=list("dobj"))$id
  extra = setdiff(c(passives, parataxis), clauses$predicate)
  if(length(extra) > 0)
    clauses = rbind(clauses, data.frame(subject=NA, predicate=extra))
  
  # add verbal xcomps
  xcomps = find_nodes(tokens, children=list(xcomp="xcomp", dobj="dobj"))
  xcomps = xcomps[!(xcomps$xcomp %in% c(block, clauses$subject)), ]
  clauses = rbind(clauses, data.frame(subject=xcomps$dobj, predicate=xcomps$xcomp))
  
  # add copula - verbs (be ready to ...)
  copx = find_nodes(tokens, children=list(nsubj="nsubj", xcomp="xcomp", cop="cop"), pos1="A", columns = "sentence")
  clauses = rbind(clauses, data.frame(subject=copx$nsubj, predicate=copx$id))
  
  # deal with conjunctions
  pred_tokens = merge(clauses, tokens[c("id", "relation", "parent")], by.x="predicate", by.y="id")
  conj = with(pred_tokens[pred_tokens$relation %in% c("conj_and", "conj_but"),], data.frame(subject=subject, predicate=parent))
  clauses = rbind(clauses, conj)
  
  clauses$clause_id = 1:nrow(clauses)
  
  # Deal with subordinate 'who' clauses
  parents = match(tokens$parent, tokens$id)
  grandparents = tokens$id[parents[parents]]
  subord_who = tokens$id[!is.na(grandparents) & tokens$lemma %in% c("who", "that") & tokens$relation[parents] == "rcmod"]
  clause_gps = grandparents[match(clauses$subject, tokens$id)]
  clauses$subject[clauses$subject %in% subord_who] = clause_gps[clauses$subject %in% subord_who]
  
  clauses[c("clause_id", "subject", "predicate")]
}


function(){
  tokens = as_tokenindex(tokens_corenlp)
  
  quote_queries = corenlp_quote_queries()  
  quote_queries
  nodes = apply_queries(tokens, quote_queries)
  annotate_nodes(tokens, nodes, 'quotes')
}