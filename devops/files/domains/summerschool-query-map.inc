# Generated when www.icos-summerschool.eu was archived: old WordPress query URLs.
# Any other page or file number was private, unpublished or members-only.
map "$arg_p$arg_page_id" $summerschool_page_redirect {
  default "";
  "~^[0-9]+$" "/unavailable/";
  "5" "/";
  "22" "/materials/";
  "27" "/feedback/";
}

map $arg_wpfb_dl $summerschool_file_redirect {
  default "";
  "~^[0-9]+$" "/unavailable/";
}
