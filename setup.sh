#!/bin/sh

__validate() {
  [[ "$1" =~ ^[a-z]([a-z0-9]|-+[a-z0-9])*$ ]] && return 0 || return 1
}

name="${PWD##*/}" # no clue why this works

__read_project_name() {
  __validate "$name" && display="($name) " || name="" display=""
  while :
  do
    read -rp "Enter a project name: $display" tmp_name
    if [[ -z "$tmp_name" ]] && [[ -z "$name" ]]; then
      >&2 echo "Only names that match '^[a-z]([a-z0-9]|-+[a-z0-9])*$' are allowed."
    else
      [[ -z "$tmp_name" ]] || name="$tmp_name"
      break
    fi
  done
}

__read_description() {
  [[ -z "$description" ]] && display="" || display="($description) "
  read -rp "Enter a short project description (one line, escape / with \/): $display" tmp_desc
  [[ -z "$tmp_desc" ]] || description="$tmp_desc"
}

__verify_state() {
  echo "Current information:"
  echo "(a) Name: $name"
  echo "(d) description: $description"
  while :
  do
    read -rp "Is this correct? (a/d/y/n) (n = abort) " yn
    case $yn in
      [Aa]* ) __read_project_name; return 1;;
      [Dd]* ) __read_description; return 1;;
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Please answer (a/d/y/n).";;
    esac
  done
  return 0;
}

copy_template() {
  mv .template/{.gitignore,*} .
}

replace_placeholders() {
  sed -i "s/%PROJECT-NAME%/$name/g" README.md
  description="$(printf '%q' "$description")"
  sed -i "s/%PROJECT-DESCRIPTION%/$description/g"

  sed -i "s/%PROJECT-NAME%/$name/g" Cargo.toml
  sed -i "s/%PROJECT-NAME%/$name/g" js/package.json
}

__read_project_name
__read_description

while :
do
  __verify_state && break
done

echo "Do not exit the script after this point"

echo "Removing old files..."
rm README.md
rm setup.sh

echo "Moving template"...
copy_template

echo "Replacing values"...
replace_placeholders

echo "Done"
