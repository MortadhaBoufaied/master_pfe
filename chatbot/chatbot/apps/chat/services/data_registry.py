class DataRegistry:
    _registry = {}

    @classmethod
    def register_components(cls, **components):
        cls._registry.update(components)

    @classmethod
    def get(cls, key, default=None):
        return cls._registry.get(key, default)
