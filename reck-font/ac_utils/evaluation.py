import numpy as np


def basic_statistics(values):
    return {'avg': np.average(values),
            'std': np.std(values),
            'var': np.var(values),
            'median': np.median(values),
            'n': len(values)
    }