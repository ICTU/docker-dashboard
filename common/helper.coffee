@Helper =
  extractTags: (appDef) -> appDef?.match(/#\s?tags:\s?([\w \d]+)\n/)?[1]?.split(' ').filter (x) -> x != null && x.length > 0
