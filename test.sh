if [ \
  "a" = "a" \
  -a "b" != "b" \
]; then
	echo "true"
else
	echo "false"
fi
