#!/usr/bin/env sh

# set -e

cd `dirname $0`/..
version=`head VERSION`
project="mcam"
release_dir="${project}"
ssh_to="mcam@mcam.iscodebaseonfire.com"

remote_ex(){
    echo ssh $ssh_to $1
    ssh $ssh_to $1
}


scp "./rel/artefacts/$project-$version.tar.gz" "$ssh_to:"


CMD="rm -rf ${release_dir}.old"
CMD+=" ; mv ${release_dir} ${release_dir}.old"
remote_ex "$CMD"

CMD="mkdir -p ${release_dir}"

CMD+=" ; cd ${release_dir} && tar zxvf ../${project}-${version}.tar.gz"

remote_ex "$CMD"

remote_ex "./${release_dir}/bin/${project} eval :migrate.up"
remote_ex "sudo systemctl stop mcam"
remote_ex "sudo systemctl enable --now mcam"
