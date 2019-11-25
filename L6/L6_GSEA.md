## 6. Vorlesung

## Gene set enrichment analysis

Viele Assays erzeugen Gen-Listen. Bei einem RNA-Seq-Experiment erhält man z.B. eine Liste aller Gene, die statistisch signifikant hoch-reguliert sind (z.B., bei uns, höher in Psoriasis als in normaler Haut). 

Wenn die Liste kurz ist, kann man die Gene manuell durchschauen.

Bei einer langen Liste kann man mit Datenbanken vergleichen.

### Einführendes Beispiel

Hier ist der MA-Plot der ANalyse der Psoriasis-Daten mit DESeq2:

![](MA_psoriasis.png)

- Für genau 48,000 Gene wurde ein Test durchgeführt.
- Von diesen sind 10,765 Gene (22.4%) statistisch signifikant hochreguliert.
- Von den 48,000 Genen sind 11 Gene dem GO-Term "RAGE receptor binding" (GO:0050786) zugeordnet.
- Von diesen 11 Genes sind 8 Gene (72%) statistisch signifikant hochreguliert
- Wenn das Experiment nichts mit dem RAGE-Repeztor zu tun hätte, würden wir erwarten, nur 22.4% der 11 Gene, also 2.46 Gene unter den hoch-regulierten zu finden.
- Hier liegt also ein 3.24-faches Enrichment vor.
- Ist das statistisch signifikant?

Dazu betrachten wir ein Urnen-Modell:
- Eine Urne enthält 48,000 Kugeln. (Eine Kugel für jedes getestete Gen.)
- Von diesen sind 11 Kugeln rot markiert. (Die RAGE-Rezeptor-bindenden Gene).
- Wir ziehen zufällig 10,765 der Kugeln aus der Urne, d.h., wir entnehmen 22.4% aller Kugeln. 
- Wie wahrscheinlich ist es, dass darunter 8 oder mehr der rot markierten Kugeln sind?

Dies bestimmt man durch den hypergeometrischen Test (auch Fisher-Test genannt, nach R. A. Fisher)

```
> rbind( c( 8, 11-8 ), c( 10765, 48000-10765 ) )
      [,1]  [,2]
[1,]     8     3
[2,] 10765 37235
```

obere Zeile: rote Kugeln
untere Zeile: weißen Kugeln
linke Spalte: gezogenen Kugeln
rechte Spalte: übrigen Kugeln

```
> fisher.test( rbind( c( 8, 11-8 ), c( 10765, 48000-10765 ) ) )

	Fisher's Exact Test for Count Data

data:  rbind(c(8, 11 - 8), c(10765, 48000 - 10765))
p-value = 0.0005444
alternative hypothesis: true odds ratio is not equal to 1
95 percent confidence interval:
  2.21318 54.04907
sample estimates:
odds ratio 
   9.22516 

```

Die Wahrscheinlichkeit, dass das aus Zufall passiert, ist also nur 0.05%. Das Enrichment ist statistisch signifikant.

Wenn 8 oder mehr rote Kugeln gezogen wurden, können wir recht sicher sein, dass die Ziehung rote und weiße Kugeln nicht gleich behaandelt hat.

Wir können die Nullhypothese verwerfen, dass es keinerlei Zusammenhang zwischen Psoriasis und dem RAGE-Rezeptor gibt.

### Gene-set enrichment analysis per Fisher-Test

Eine Liste von Genen, wie zB die Liste der 11 Gene, die zur GO-Kategorie "RAGE receptor binding" gehören, nennen wir ein "gene set" oder eine "gene category".

Wenn wir eine Sammlung solcher Gen-Sets haben, können wir für jedes Gen-Set einen Fisher-Test durchführen.

Gegeben:
- A: eine Liste von Genen als Ergebnis eines Experiments, z.B. die Liste aller statistisch signifikant hochregulierten Gene
- B: die Liste von Genen, die im Experiment untersucht wurden, und zwar mit einer Genauigkeit, die ausreichen war, um einen statistisch signifikanten Effekt zu erkennen ("gene universe" oder "background list")
- C: eine Sammlung von Gene-Sets, also von Listen von Genen, aus einer Datenbank, z.B. die Sammlung aller GO-Kategorien und die ihnen zugeordneten menschlichen Gene

Vorgehen:
- Ermittle für jedes Gen-Set aus C, ob es in Ergebnisliste A stärker vertreten ("enriched") ist als man erwarten würde, wenn das Gen-Set eine Liste von Genen wäre, die man rein zufällig aus dem Universum B ausgewählt hat.

Ergebnis:
- Für jedes Gene-Set ein Enrichment-Faktor und ein zugeordneter p-Wert.

Vorsicht:
- Ein signifikantes Enrichment bedeutet keine Kausalität.
- Die Ergebnisse hängen stark vom gewählten Grenzwert für die Bewertung des Signifikanz in A ab.
- Die statistische Power hängt von der Größe der Gen-Sets ab; das macht die p-Werte schwer interpretierbar

### Sammlungen von Gene-Sets

- Gene Ontology (GO)
- Kyoto Encyclopedia of Genes and Genomes (KEGG)
- Reactome
- Molecular Signatures Database (MSigDb)


#### Gene Ontology

Die Gene Ontology besteht aus

- den GO-Termen (universell)
- der Zuordnung von Genen zu GO-Termen (separat für jede Spezies)

Die GO-Terme formen drei komplementäre Teil-Ontologien:
- cellular components (CC)
- biological processes (BP)
- molecular functions (MF)

Jede Teil-Ontologie ist ein ungerichteter azyklische Graph (directed acyclic graph, DAG)

GO dient dazu, unser Wissen über Gene digital zu erfassen.

#### KEGG und Reactome

Beides sind Datenbank von Netzen biochemischer Reaktionen

KEGG ist kostenpflichtig, Reactome ist frei.


#### MSigDb

Die MSigDb wurde explizit für Gene-Set-Enrichment-Analyse konzipiert.

Sie hat mehrere Kollektionen, siehe Web-Seite




### Gene-set enrichment analysis (GSEA) per KS-Statistik

Idee:

- Sortiere alle Gene, die im Experiment gut quantifiziert wurden, nach einer Score (typischerweise der log-Fold-Change)
- Markiere in der sortierten Liste die Gene, die zum Gen-Set gehören.
- Frage: Sind die markierten Gene gleichmäßig verteilt, oder sind sie bevorzugt z.B. am Anfang oder am Ende der Liste? 

![](lfc_rank.png)

Berechnen der KS-Statistik:
- Starte mit 0
- Gehe durch die Liste, addiere $d_1$, wenn du ein Gen aus den Gene-Set siehst und subtrahiere $d_2$ sonst.
- Wenn die Liste $n$ Gene enthält, und davon $k$ im Gen-Set sind, wähle $d_1=1/k$ und $d_2=1/(n-k)$. So kommst du am Ende wieder bei 0 an.
- Der extremste Wert, den du dabei unterwegs siehst, ist die Kolmogorov-Smirnov-Statistik (KS-Statistik). 

![](ks.png)

Wann ist die KS-Statstik signifikant?

Zwei Möglichkeiten

- Permutiere die Liste, d.h. mache die Reihenfolge der Gene zufällig, berechne nochmals die Statistik. Führe viele Permutationen durch und schaue, welcher Anteil dieser Werte extremer ist als der echte Wert. Diese Anteil istd er p-Wert
    - Tatsächlich muss man die Permutationen nicht durchführen: Kolmogov und Smirnov haben eine Formel gefunden, um den Anteil direkt zu berechnen (sog. KS-Test).
- Permutiere die Zuordnung der Proben zu den Labels (zB Cases und Controls), um Permutations-Werte der Log-Fold-Changes zu erhalten. Berechne die KS-STatistik für diese permutierten Werte.

Die zweite Variante ist, was in der Literatur oft als GSEA im engeren Sinne bezeichnet wird.
