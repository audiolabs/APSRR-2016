import matplotlib.pyplot as plt
import numpy as np
import seaborn
seaborn.set(style="dark")


def plot_waveform(audio, sample_rate=44100, show=True, title=None):
    plt.figure()
    if title is not None:
        plt.title(title)
    time = np.linspace(0, len(audio)/sample_rate, num=len(audio))
    plt.plot(time, audio)
    if show:
        plt.show()


def plot_waveform_with_ticks(audio, ticks, sample_rate=44100, show=True, title=None):
    plt.figure()
    if title is not None:
        plt.title(title)
    for tick in ticks:
        plt.vlines(tick, 0, 1, label='tick', color='r')
    time = np.linspace(0, len(audio)/sample_rate, num=len(audio))
    plt.plot(time, audio)
    if show:
        plt.show()


def annotate_point_pair(ax, text, xy_start, xy_end, xycoords='data', text_offset=6, textx_offset=0, text_size=12, arrowprops=None):
    """
    Taken from: http://stackoverflow.com/a/32522399
    Annotates two points by connecting them with an arrow.
    The annotation text is placed near the center of the arrow.
    """

    if arrowprops is None:
        arrowprops = dict(arrowstyle= '<->', facecolor='black', linewidth=1.0)

    assert isinstance(text,str)

    xy_text = ((xy_start[0] + xy_end[0])/2. + textx_offset, (xy_start[1] + xy_end[1])/2.)
    arrow_vector = xy_end[0]-xy_start[0] + (xy_end[1] - xy_start[1]) * 1j
    arrow_angle = np.angle(arrow_vector)
    text_angle = arrow_angle - 0.5*np.pi

    ax.annotate(
            '', xy=xy_end, xycoords=xycoords,
            xytext=xy_start, textcoords=xycoords,
            arrowprops=arrowprops)

    label = ax.annotate(
        text,
        xy=xy_text,
        xycoords=xycoords,
        xytext=(text_offset * np.cos(text_angle), text_offset * np.sin(text_angle)),
        textcoords='offset points', size=text_size)

    return label