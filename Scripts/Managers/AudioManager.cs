using Godot;
using System;

namespace UpBall.Managers;

/// <summary>
/// Singleton para gerenciar áudio do jogo.
/// </summary>
public partial class AudioManager : Node
{
    public static AudioManager Instance { get; private set; }

    // Audio players
    private AudioStreamPlayer _sfxPlayer;
    private AudioStreamPlayer _musicPlayer;

    // Sound effects (load these in _Ready or via export)
    [Export] public AudioStream SfxBallRoll { get; set; }
    [Export] public AudioStream SfxGameOver { get; set; }
    [Export] public AudioStream SfxVictory { get; set; }
    [Export] public AudioStream SfxHoleHit { get; set; }

    // Settings
    public float SfxVolume { get; set; } = 1.0f;
    public float MusicVolume { get; set; } = 0.7f;
    public bool SfxEnabled { get; set; } = true;
    public bool MusicEnabled { get; set; } = true;

    public override void _Ready()
    {
        Instance = this;
        SetupAudioPlayers();
    }

    private void SetupAudioPlayers()
    {
        _sfxPlayer = new AudioStreamPlayer();
        _sfxPlayer.Bus = "SFX";
        AddChild(_sfxPlayer);

        _musicPlayer = new AudioStreamPlayer();
        _musicPlayer.Bus = "Music";
        AddChild(_musicPlayer);
    }

    public void PlaySfx(AudioStream stream)
    {
        if (!SfxEnabled || stream == null) return;
        
        _sfxPlayer.Stream = stream;
        _sfxPlayer.VolumeDb = Mathf.LinearToDb(SfxVolume);
        _sfxPlayer.Play();
    }

    public void PlayGameOver()
    {
        PlaySfx(SfxGameOver);
        TriggerHaptic();
    }

    public void PlayVictory()
    {
        PlaySfx(SfxVictory);
    }

    public void PlayHoleHit()
    {
        PlaySfx(SfxHoleHit);
        TriggerHaptic();
    }

    public void TriggerHaptic()
    {
        // Vibração no dispositivo móvel
        Input.VibrateHandheld(100);
    }

    public void StopAllSounds()
    {
        _sfxPlayer.Stop();
        _musicPlayer.Stop();
    }
}
