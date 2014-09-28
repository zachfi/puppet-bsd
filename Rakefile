# Thank rtyler for donating some code.
#
# https://gist.github.com/rtyler/3041462
#
LINT_IGNORES = ['rvm']

desc "Validate the manifests"
task :validate do
  list = FileList['**/*.pp'].join(' ')
  puts "Validating manifests"
  %x{puppet parser validate #{list}}
end
