## Übersicht über die R-Funktionen zur Tabellen-Manipulation,
die wir in der Vorlesung besprochen haben.

Um ausführlichere Erklärungen oder Beispiele zu finden, siehe den Code von den Vorlesungen -- oder
man googelt einfach nach "R" oder "tidyverse" und dem Funkltionsnamen.



### library( tidyverse )

Laedt die Tidyverse-Pakete, die viele der folgenden Funktionen bereitstellen


### %>%

Pipe-Operator: "schiebt" Daten von einem Befehl zum nächsten (oder schiebt Daten aus einer V ariable in einen Befehl)

Technisches: `v %>% f(y)` ist eigentlich einfach nur eine alternative Schreibweise von `f( x, y)`, d.h., das "Hinein-Geschobene" ist das erste Argument von `f` und `y` ist das zweite.


### ->

Zuweisungs-Operator: `f(x) -> y` speichert das Resultat von `f(x)` in der Variable `y`

Technisches: Man kann auch `y <- f(x)` schreiben, oder `y = f(x)`; dies sind alles alternative Schreibweisung derselben ZUweisungs-Operation


### read_tsv

Einlesen einer Daten-Tabelle aus einer Text-Datei. "tsv" steht für "Tab-separated values". Es gibt auch "csv", "comma-separated values", und einiges mehr. Die NHANES-Daten zB lagen in dem wenig bekannten "XPT"-Format vor, dass wir mit `read_xpt` eingelesen haben.


### select

wählt Spalten einer Tabelle aus; die übrigen Spalten werden nicht weiter gereicht. Man kann den Spalten auch neue Namen geben. Wenn man den Spaltennamen ein
"-" voranstellt, bedeutet das: alle Spalten außer diesen.


### mutate

verändert Spalte der durchgereichten Tabelle, oder fügt eine neue Spalten hinzu. Man gibt eine Rechenoperation an, die die neuen Werte für die Spalte aus den anderen Spalten berchnet, zB: `tbl %>% mutate( bmi = weight / height^2 )`


### fct_recode

benennt die Levels in einem Faktor um. Ein Faktor ist eine Spalte mit Strings (Zeichenketten) aus einer vorgegebenen Liste von Levels. Bsp.: Eine Spalte, die nur die Werte "male" und "female" enthält. Rekodieren heisst, diese Werte durch andere (zB "Mann" und "Frau") zu ersetzen.

Beispiel: `tbl %>% mutate( sex = fct_recode( sex, "Mann"="male", "Frau"="female ) )`

Hier verändern wir mit `mutate` die Spalte `sex`. Die neuen Werte enstehen aus den alten Werten durch Umkodierung: "male" wird durch "Mann" ersetzt und "female" durch "Frau".


### filter

wählt bestimmte Zeilen aus und verwirft die anderen. Beispiel: `tbl %>% filter( age >= 18 )` behält nur die Tabellen-Zeilen bei, in denen der Wert in der Spalte `age` mindestens 18 ist.

Mehrere Filter-Kriterien können durch ein Komma oder ein `&`-Zeichen (beides für "und") oder durch ein `|`-Zeichen (für "oder") verknüpft werden


### group_by

fasst die Zeilen der Tabelle zu Gruppen zusammen. Beispiel: `tbl %>% group_by( sex )` ordnet die Zeilen in zwei Gruppen, die Zeilen mit `sex=="male"` und die mit `sex=="female"`. Alle folgenden Operation (z.B. Mittelwerte) werden nun für jede Gruppe getrennt durch geführt.


### summerise

Fasst alle Zeilen einer Gruppe zu einer einzigen Zahl (z.B. ein Mittelwert) zusammen.

Beispiel: `tbl %>% group_by( sex ) %>% summarise( mean_height = mean(height) )` berechnet den Mittelwert (`mean`) der Werte in der Spalte `height`, getrennt für die Werte mit `sex=="male"` und `sex=="female"`

Nützliche Funktionen, die man in `summerise` verwenden kann, sind zB `mean` (Mittelwert), `sum` (Summe), `var` (Varianz), `sd` (Standardabweichung), `n` (Anzahl) usw.


### left_join und inner_join

fügt zwei Tabellen zusammen: an jede Zeile der linken Tabelle wird die passende Zeile der rechten Tabelle angefügt. Die linke Tabelle ist dabei diejenige, die über `%>%` in den Befehl hineingeschoben wurde (oder die zuerst angeben wird, wenn man keine `%>%`-Pipe verwendet), die rechte Tabelle die, die in den Klammern nach `left_join` angegeben ist (oder die zweite der beiden Tabellen zwischen den Klammern, falls kein `%>%` verwendet wurde). Dass Zeilen zusammen gehören, wird daran erkannt, dass ihre Werte übereinstimmen in all den Spalten, die in beiden Tabellen vorkommen. Mit dem `by`-Argument kann man explizit angeben, welche Spalten abgeglichen werden sollen. Wenn in der rechten Tabelle keine passende Zeile gefunden wird, werden die Felder als fehlend (markiert mit `NA`, für "not available") angefügt. Falls in der rechten Tabelle mehrere passende Zeilen gefunden werden, wird die Zeile in der linken Tabelle vervielfacht. Neben `left_join` gibt es auch noch `inner_join`, dass die Zeilen weglässt, die nicht in beiden Tabellen gefunden werden (statt `NA`s zu setzen), und ein paar weitere join-Arten.

### gather

wandelt eine "breite" Tabelle in eine "lange" Tabelle um. Dabei gibt man erst die Namen der zwei neuen Spalten an, die man erhalten möchte (Schlüssel- und Werte-Spalte), und listet dann die Spalten, die man "einsammeln" möchte. Danach enthält die Schlüssel-Spalte , was vorher dir Überschriften der eingesammelten Spalten waren, und die Werte-Spalte die Werte in den eingesammelten Spalten. Beispiel: `countsWide` zu `countsLong` in unserem Psoriasis-Beispiel. Beim Angeben der einzusammelnden Spalten hilft oft die Minus-Syntax: anstatt der einzusammelnden Spalten gibt man die andern Spalten an, mit Minuszeichen vor dem Namen. Das Minuszeichen bedeutet "alle Spalten außer diesen".


### spread

die umgekehrte Operation zu gather: Man gibt eine Schlüssel- und eine Werte-Spalte an: Für jedes Level in der Schlüssel-Spalte wird eine neue Spalte angelegt, mit dieser Überschrift, und die Werte aus der Werte-Spalte werden darunter verteilt.


### head und tail

'head` behält nur die ersten 10 Zeilen (oder die ersten *n* Zeilen, für `head(n)`). Das iost nützlich, um zu verhindern, dass die vielen Zeilen eine langen Tabelle den Bildschirm verstopfen. Ebenso gibt es `tail`, um einen Blick auf die letzten 10 Zeilen zu werfen.


