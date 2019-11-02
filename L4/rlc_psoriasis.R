library( tidyverse )
devtools::install_github("anders-biostat/rlc")
library( rlc )

read_tsv( "../L3/counts_gene.tsv.gz" ) ->  countsWide

read_tsv( "../L3/SRP035988.tsv" ) %>%
  select( sample = run, subject = title, condition = characteristics ) %>%
  mutate( condition = fct_recode( condition,
    "normal" = "tissue type: normal skin",
    "psoriatic" = "tissue type: lesional psoriatic skin" ) ) -> sampleTable

read_tsv( "../L3/gene_ids.tsv" ) -> genes

countsWide %>%
  gather( sample, count, -gene_id ) -> countsLong

countsLong %>%
group_by( sample ) %>%
summarize( total = sum( count ) ) -> totals

countsLong %>%
mutate( gene_id = str_remove( gene_id, "\\.\\d+")) %>%
left_join( totals ) %>%
mutate( tpm = count / ( total / 1000000 ) ) %>%
select( gene_id, sample, tpm ) -> tpmTable

tpmTable %>%
left_join( sampleTable ) %>%
group_by( gene_id, condition ) %>%
summarize( 
  mean = mean( tpm ),
  sem = sd( tpm ) / sqrt(n()) ) %>%
gather( key, value, mean, sem ) %>%
unite( key, condition, key ) %>%
spread( key, value ) %>%
mutate( ratio = psoriatic_mean / normal_mean ) %>%
left_join( genes ) -> resultTable

openPage( FALSE, layout="table2x2" )

lc_scatter(
  dat(
    x = ( resultTable$normal_mean + resultTable$psoriatic_mean )/2,
    y = resultTable$ratio,
    label = resultTable$name,
    on_click = function(k) { i <<- k; updateCharts(c("A2", "B1")) } ),
  logScaleX = 10,
  logScaleY = 2,
  title = "all genes",
  size = 1.5,
  place = "A1" )

i <- 1

sampleTable %>%
  arrange( condition ) -> sampleTableArr

lc_scatter(
  dat(
    x = sampleTableArr$subject,
    y = ( tpmTable %>% 
          filter( gene_id==resultTable$gene_id[i] ) %>% 
          right_join( sampleTableArr ) %>% 
          pull( tpm ) ) + 0.0001,
    colourValue = sampleTableArr$condition,
    title = paste0( "Gene ", resultTable$name[i] ) ),
  logScaleY = 10,
  place = "A2",
  ticksRotateY = 90
)

lc_html(
  dat( content = str_glue( 
  "<h4>Gene <b>{resultTable$name[i]}</b>:</h4>", 
  "<p>{resultTable$description[i]}</p>",
  "<p>Ensembl ID: {resultTable$gene_id[i]}</p>",
  "<p><a href='http://en.wikipedia.org/wiki/{resultTable$name[i]}'>Wikipedia page on {resultTable$name[i]}</a></p>",
  "<p><table border='1' cellpadding='6px'><tr><td>FPM</td><td>mean</td><td>std err</td></tr>",
  "<tr><td>psoriasis</td><td>{signif( resultTable$psoriatic_mean[i], 5)}</td><td>{signif( resultTable$psoriatic_sem[i], 3)}</td></tr>",
  "<tr><td>normal</td><td>{signif( resultTable$normal_mean[i], 5 )}</td><td>{signif( resultTable$normal_sem[i], 3)}</td></tr>",
  "</table></p>" ) ),
  place = "B1" )
