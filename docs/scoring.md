# Scoring

Le scoring actuel est numérique. Il produit un score global de `0` à `100` dans `ScoreSummary.Score`.

Il n'existe plus de niveau de maturité littéral dans le MVP stabilisé.

## Poids par sévérité

| Sévérité | Pénalité par élément |
| --- | ---: |
| `Critical` | 20 |
| `High` | 10 |
| `Medium` | 5 |
| `Low` | 2 |
| `Info` | 0 |

## Calcul

Le moteur parcourt tous les findings et applique la formule :

```text
Pénalité totale = somme(Poids de la sévérité * Count du finding)
Score = 100 - Pénalité totale
```

Si le score calculé descend sous `0`, il est ramené à `0`.

## Rôle de Count

`Count` représente le nombre d'éléments concernés par un finding. C'est ce champ qui amplifie la pénalité.

Exemple :

```text
Finding High avec Count = 3
Pénalité = 10 * 3 = 30
```

Un finding sans `Count`, avec un `Count` non numérique ou avec une valeur négative est traité comme `0` pour le scoring.

## Synthèse

Le rapport JSON expose aussi le nombre de findings par sévérité :

- `Critical`
- `High`
- `Medium`
- `Low`
- `Info`

Ces compteurs indiquent le nombre de findings, pas le nombre total d'éléments affectés.
