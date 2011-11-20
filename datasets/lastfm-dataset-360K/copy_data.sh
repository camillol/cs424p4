psql cs424p4 -c "copy users from stdin with null '';" < '/Users/camillo/uic/CS424 visualization/p4/datasets/lastfm-dataset-360K/userid-profile.tsv'

sed 's|\\|\\\\|g' < '/Users/camillo/uic/CS424 visualization/p4/datasets/lastfm-dataset-360K/artid-artmbid-artname.tsv' | psql cs424p4 -c "copy artists from stdin with null '';"

sed 's|\\|\\\\|g' < '/Users/camillo/uic/CS424 visualization/p4/datasets/lastfm-dataset-360K/userid-artid-plays.tsv' | psql cs424p4 -c "copy users_artists from stdin with null '';"
