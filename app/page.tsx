'use client'

import { useState, useRef, useMemo } from 'react'

interface Video {
  id: string
  title: string
  video_url: string
  thumbnail_url: string
  description?: string
}

const R2_BASE_URL = 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev'

// Videos from Cloudflare R2
const mockVideos: Video[] = [
  {
    id: '1',
    title: 'Video 1',
    video_url: `${R2_BASE_URL}/IMG_0986.MOV`,
    thumbnail_url: '/6.png',
  },
  {
    id: '2',
    title: 'Video 2',
    video_url: `${R2_BASE_URL}/IMG_0988.MOV`,
    thumbnail_url: '/7.png',
  },
  {
    id: '3',
    title: 'Video 3',
    video_url: `${R2_BASE_URL}/IMG_0990.MOV`,
    thumbnail_url: '/8.png',
  },
  {
    id: '4',
    title: 'Video 4',
    video_url: `${R2_BASE_URL}/IMG_0992.MOV`,
    thumbnail_url: '/1.png',
  },
  {
    id: '5',
    title: 'Video 5',
    video_url: `${R2_BASE_URL}/IMG_0993.MP4`,
    thumbnail_url: '/2.png',
  },
  {
    id: '6',
    title: 'Video 6',
    video_url: `${R2_BASE_URL}/IMG_0994.MP4`,
    thumbnail_url: '/3.png',
  },
  {
    id: '7',
    title: 'Video 7',
    video_url: `${R2_BASE_URL}/IMG_0995.MP4`,
    thumbnail_url: '/4.png',
  },
  {
    id: '8',
    title: 'Video 8',
    video_url: `${R2_BASE_URL}/IMG_0996.MP4`,
    thumbnail_url: '/5.png',
  },
  {
    id: '9',
    title: 'Ustoz AI Interview 1',
    video_url: `${R2_BASE_URL}/AQPYJZa6X1RxDwRQEyUziXiCUvAjUd9LcnKBQNdGBfc1Hb1VucwZIvqMQk1_aod.mp4`,
    thumbnail_url: '/9.png',
  },
  {
    id: '10',
    title: 'Ustoz AI Interview 2',
    video_url: `${R2_BASE_URL}/IMG_1250.MOV`,
    thumbnail_url: '/11.png',
  },
  {
    id: '11',
    title: 'Ustoz AI Interview 3',
    video_url: `${R2_BASE_URL}/IMG_1251.MOV`,
    thumbnail_url: '/12.png',
  },
  {
    id: '12',
    title: 'Ustoz AI Interview 4',
    video_url: `${R2_BASE_URL}/IMG_1252.MOV`,
    thumbnail_url: '/10.png',
  },
  {
    id: '13',
    title: 'Ustoz AI Interview 5',
    video_url: `${R2_BASE_URL}/IMG_1253.MOV`,
    thumbnail_url: '/13.png',
  },
  {
    id: '14',
    title: 'Ustoz AI Interview 6',
    video_url: `${R2_BASE_URL}/IMG_1253.MOV`,
    thumbnail_url: '/14.png',
  },
  {
    id: '15',
    title: 'Ustoz AI Interview 7',
    video_url: `${R2_BASE_URL}/IMG_1255.MOV`,
    thumbnail_url: '/15.png',
  },
]

// Group videos into pages of 4 (2x2 grid)
function chunkArray<T>(array: T[], size: number): T[][] {
  const chunks: T[][] = []
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size))
  }
  return chunks
}

export default function Home() {
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null)
  const [isPaused, setIsPaused] = useState(false)
  const videoRef = useRef<HTMLVideoElement>(null)

  // Split videos into pages of 4
  const videoPages = useMemo(() => chunkArray(mockVideos, 4), [])

  const togglePlayPause = () => {
    if (videoRef.current) {
      if (videoRef.current.paused) {
        videoRef.current.play()
        setIsPaused(false)
      } else {
        videoRef.current.pause()
        setIsPaused(true)
      }
    }
  }

  const handleCloseVideo = () => {
    setSelectedVideo(null)
    setIsPaused(false)
  }

  return (
    <main className="swipe-container">
      {videoPages.map((pageVideos, pageIndex) => (
        <section key={pageIndex} className="video-page">
          <div className="grid-2x2">
            {pageVideos.map((video) => (
              <div
                key={video.id}
                className="video-card"
                onClick={() => setSelectedVideo(video)}
              >
                <div className="thumbnail-container">
                  <img
                    src={video.thumbnail_url}
                    alt={video.title}
                    className="thumbnail"
                    loading="lazy"
                  />
                  <div className="overlay">
                    <svg className="play-icon" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M8 5v14l11-7z" />
                    </svg>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </section>
      ))}

      {selectedVideo && (
        <div
          className="modal-backdrop"
          onClick={(e) => {
            if (e.target === e.currentTarget) {
              handleCloseVideo()
            }
          }}
        >
          <div className="modal-content">
            <button
              className="back-button"
              onClick={handleCloseVideo}
              aria-label="Go back"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M19 12H5M12 19l-7-7 7-7" />
              </svg>
            </button>

            <div className="video-wrapper" onClick={togglePlayPause}>
              <video
                ref={videoRef}
                src={selectedVideo.video_url}
                autoPlay
                loop
                playsInline
                className="video-element"
              >
                Your browser does not support the video tag.
              </video>
              
              {isPaused && (
                <div className="pause-overlay">
                  <div className="play-button-large">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                      <path d="M8 5v14l11-7z" />
                    </svg>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </main>
  )
}
