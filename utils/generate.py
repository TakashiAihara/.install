from os.path import join, basename, dirname
from os import makedirs
from glob import glob
import json

import yaml
from dotenv import dotenv_values

env = dotenv_values(".env")

suffix = env.get("DOTBOT_CONFIG_FILE_SUFFIX") or ""
config_dir = env.get("DOTBOT_INSTALL_CONFIG_DIR") or ""
target_dir = env.get("DOTBOT_CONFIG_TARGET_DIR") or ""
step_base_dir = env.get("DOTBOT_STEPS_BAES_DIR") or ""
specs = json.loads(env.get("DOTBOT_YAML_SPECS") or "[]")


class Loader(yaml.SafeLoader):
    def __init__(self, stream):
        super(Loader, self).__init__(stream)

    def include(self, node: yaml.ScalarNode):
        step_dir = node.tag.replace("!", "")
        steps = str(self.construct_scalar(node)).split(" ")
        step_content: str = ""
        for step in steps:
            filename = join(step_base_dir, step_dir, step + suffix)
            with open(filename, "r") as f:
                step_content += f.read()

        return yaml.load(step_content, Loader)


for spec in specs:
    Loader.add_constructor(spec, Loader.include)


def generate_yaml(origin_path: str, target_path: str):
    makedirs(dirname(target_path), exist_ok=True)

    with open(origin_path, "r") as f:
        data = yaml.load(f, Loader)
    yaml.dump(data, open(target_path, "w"))

    print(f"generated {origin_path} into {target_path}")


for origin in glob(f"{config_dir}/*{suffix}"):
    target = join(target_dir, basename(origin))
    generate_yaml(origin, target)
